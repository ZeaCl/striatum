defmodule Striatum.TransactionServer do
  @moduledoc """
  GenServer that manages the lifecycle of a single transaction.

  Each transaction gets its own process. The process:
  1. Calls the acquirer to authorize the payment
  2. Transitions state based on acquirer response
  3. Triggers DTE generation on success (Sprint 3)
  4. Dispatches webhooks on terminal states
  5. Sends signal to Cerebelum on completion (Sprint 6)

  If the process crashes, the supervisor restarts it from the last
  persisted state in the database.
  """
  use GenServer

  alias Striatum.{Repo, Transaction, TransactionManager}

  require Logger

  # Client API

  @doc """
  Starts a TransactionServer for the given transaction.
  """
  def start_link(%Transaction{} = transaction, opts \\ []) do
    GenServer.start_link(__MODULE__, transaction, opts)
  end

  @doc """
  Triggers the authorization process for the transaction.
  """
  def authorize(pid), do: GenServer.cast(pid, :authorize)

  @doc """
  Triggers DTE invoicing after successful authorization.
  """
  def start_invoicing(pid), do: GenServer.cast(pid, :start_invoicing)

  @doc """
  Gets current transaction state.
  """
  def get_state(pid), do: GenServer.call(pid, :get_state)

  # Server Callbacks

  @impl true
  def init(%Transaction{} = transaction) do
    Logger.debug("TransactionServer started for #{transaction.id}")
    {:ok, transaction}
  end

  @impl true
  def handle_cast(:authorize, %Transaction{status: :pending} = tx) do
    adapter = get_adapter()

    params = %{
      card_token: "tok_visa_#{tx.id}",
      amount: tx.amount,
      currency: tx.currency,
      description: "Payment for #{tx.product_id || "service"}",
      metadata: tx.metadata
    }

    case adapter.authorize(params) do
      {:ok, auth_result} ->
        tx
        |> Transaction.changeset(%{
          acquirer_tx_id: auth_result.acquirer_tx_id,
          card_last4: auth_result.card_last4,
          card_brand: auth_result.card_brand,
          acquirer_response: Map.from_struct(auth_result)
        })
        |> Repo.update!()

        {:ok, tx} = TransactionManager.transition(tx, :authorized)

        # Trigger SII invoicing if credentials are configured
        maybe_start_invoicing(tx)

        {:noreply, tx}

      {:error, :declined} ->
        tx
        |> Transaction.changeset(%{acquirer_response: %{reason: "declined"}})
        |> Repo.update!()

        {:ok, tx} = TransactionManager.transition(tx, :declined)
        dispatch_webhook(tx, "transaction.declined")
        {:noreply, tx}

      {:error, :timeout} ->
        Logger.warning("Acquirer timeout for #{tx.id} — retrying")
        Process.send_after(self(), {:retry_authorize, 1}, :timer.seconds(2))
        {:noreply, tx}

      {:error, :invalid_token} ->
        {:ok, tx} = TransactionManager.transition(tx, :failed)
        {:noreply, tx}
    end
  end

  def handle_cast(:authorize, tx), do: {:noreply, tx}

  @impl true
  def handle_info({:retry_authorize, attempt}, %Transaction{status: :pending} = tx) do
    if attempt > 5 do
      Logger.error("All authorization retries exhausted for #{tx.id}")
      {:ok, tx} = TransactionManager.transition(tx, :failed)
      dispatch_webhook(tx, "transaction.failed")
      {:noreply, tx}
    else
      delay = trunc(:math.pow(2, attempt) * 1000)

      adapter = get_adapter()

      params = %{
        card_token: "tok_visa_#{tx.id}",
        amount: tx.amount,
        currency: tx.currency,
        description: "Payment for #{tx.product_id || "service"}",
        metadata: tx.metadata
      }

      case adapter.authorize(params) do
        {:ok, auth_result} ->
          tx
          |> Transaction.changeset(%{
            acquirer_tx_id: auth_result.acquirer_tx_id,
            card_last4: auth_result.card_last4,
            card_brand: auth_result.card_brand,
            acquirer_response: Map.from_struct(auth_result)
          })
          |> Repo.update!()

          {:ok, tx} = TransactionManager.transition(tx, :authorized)
          maybe_start_invoicing(tx)
          {:noreply, tx}

        {:error, :timeout} ->
          Logger.warning("Acquirer retry #{attempt}/5 failed for #{tx.id}")
          Process.send_after(self(), {:retry_authorize, attempt + 1}, delay)
          {:noreply, tx}

        {:error, :declined} ->
          {:ok, tx} = TransactionManager.transition(tx, :declined)
          dispatch_webhook(tx, "transaction.declined")
          {:noreply, tx}

        {:error, :invalid_token} ->
          {:ok, tx} = TransactionManager.transition(tx, :failed)
          {:noreply, tx}
      end
    end
  end

  def handle_info({:retry_authorize, _attempt}, tx), do: {:noreply, tx}

  @impl true
  def handle_call(:get_state, _from, tx), do: {:reply, tx, tx}

  # Private

  defp get_adapter do
    Application.get_env(:striatum, :acquirer_adapter, Striatum.AcquirerAdapter.Mock)
  end

  defp maybe_start_invoicing(tx) do
    case Repo.get_by(Striatum.SiiCredential, organization_id: tx.organization_id, is_active: true) do
      nil ->
        {:ok, _tx} = TransactionManager.transition(tx, :completed_no_invoice)
        dispatch_webhook(tx, "transaction.completed_no_invoice")

      _creds ->
        {:ok, _tx} = TransactionManager.transition(tx, :invoicing)

        %{transaction_id: tx.id}
        |> Striatum.Jobs.SiiSubmissionJob.new()
        |> Oban.insert()
    end
  end

  defp dispatch_webhook(tx, event_type) do
    Striatum.WebhookDispatcher.dispatch(tx, event_type)

    if event_type == "transaction.completed" do
      Striatum.CerebelumAdapter.send_payment_completed(tx)
    end

    :ok
  end
end
