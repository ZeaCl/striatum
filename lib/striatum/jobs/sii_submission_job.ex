defmodule Striatum.Jobs.SiiSubmissionJob do
  @moduledoc """
  Oban job that submits a DTE to the SII.

  Handles retry logic with exponential backoff.
  Max 5 retries before marking as invoice_pending_manual.
  """
  use Oban.Worker,
    queue: :sii_submission,
    max_attempts: 6,
    unique: [period: 300]

  alias Striatum.{Repo, Transaction, DTE, TransactionManager}

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"transaction_id" => tx_id}, attempt: attempt}) do
    tx = Repo.get!(Transaction, tx_id)

    cond do
      attempt > 5 ->
        Logger.error("All SII retries exhausted for transaction #{tx_id}")
        {:ok, _tx} = TransactionManager.transition(tx, :invoice_pending_manual)
        :ok

      true ->
        do_submit(tx)
    end
  end

  @impl true
  def backoff(%Oban.Job{attempt: attempt}) do
    # Exponential backoff: 5s, 10s, 20s, 40s, 60s
    backoffs = [5, 10, 20, 40, 60]
    Enum.at(backoffs, attempt - 1, 60)
  end

  # -- Private --

  defp do_submit(tx) do
    with {:ok, dte} <- Repo.get_by(DTE, transaction_id: tx.id) |> ensure_dte(tx),
         :ok <- submit_to_sii(tx, dte) do
      {:ok, tx} = TransactionManager.transition(tx, :completed)
      Striatum.WebhookDispatcher.dispatch(tx, "transaction.completed")
      :ok
    else
      {:error, :timeout} ->
        Logger.warning("SII timeout for transaction #{tx.id} — will retry")
        {:error, :timeout}

      {:error, :rejected} ->
        Logger.warning("SII rejected DTE for transaction #{tx.id}")

        tx
        |> Transaction.changeset(%{status: :invoice_failed})
        |> Repo.update!()

        Repo.get_by!(DTE, transaction_id: tx.id)
        |> Ecto.Changeset.change(%{sii_status: :rejected, sii_error_code: "REJECTED_BY_SII"})
        |> Repo.update!()

        :ok

      {:error, :out_of_folios} ->
        Logger.error("Out of SII folios for transaction #{tx.id}")
        {:ok, _tx} = TransactionManager.transition(tx, :invoice_pending_manual)
        :ok
    end
  end

  defp ensure_dte(nil, tx), do: Striatum.DTEBuilder.build(tx)
  defp ensure_dte(dte, _tx), do: {:ok, dte}

  defp submit_to_sii(tx, dte) do
    credentials = Repo.get_by(Striatum.SiiCredential, organization_id: tx.organization_id)
    rut_emisor = if credentials, do: credentials.rut, else: "66666666-6"
    branch_code = if credentials, do: credentials.branch_code, else: "1"

    adapter = Application.get_env(:striatum, :sii_adapter, Striatum.SIIAdapter.Mock)

    result =
      adapter.submit_dte(%{
        rut_emisor: rut_emisor,
        rut_receptor: tx.metadata["customer_rut"] || "66666666-6",
        monto: tx.amount,
        folio: dte.folio,
        tipo_dte: 33,
        branch_code: branch_code,
        organization_id: tx.organization_id
      })

    case result do
      {:ok, _sii_response} ->
        dte
        |> Ecto.Changeset.change(%{
          sii_status: :accepted,
          accepted_at: DateTime.utc_now(),
          submitted_at: DateTime.utc_now()
        })
        |> Repo.update!()

        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
