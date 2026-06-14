defmodule StriatumWeb.TransactionController do
  use StriatumWeb, :controller

  alias Striatum.{TransactionManager, TransactionServer, TransactionSupervisor, Transaction, Repo}

  @doc "POST /v1/transactions"
  def create(conn, params) do
    org_id = get_org_id(conn)

    with {:ok, tx} <- TransactionManager.create(params, org_id) do
      if tx.status == :pending do
        {:ok, pid} = TransactionSupervisor.start_child(tx)
        TransactionServer.authorize(pid)

        conn
        |> put_status(202)
        |> json(%{transaction: serialize_transaction(tx)})
      else
        conn
        |> put_status(200)
        |> json(%{transaction: serialize_transaction(tx)})
      end
    else
      {:error, :duplicate} ->
        conn
        |> put_status(409)
        |> json(%{
          error: %{code: "duplicate_transaction", message: "Idempotency key already used"}
        })

      {:error, %Ecto.Changeset{} = cs} ->
        field = cs.errors |> List.first() |> elem(0)

        conn
        |> put_status(422)
        |> json(%{error: %{code: "invalid_#{field}", message: "Validation failed"}})
    end
  end

  @doc "GET /v1/transactions/:id"
  def show(conn, %{"id" => id}) do
    org_id = get_org_id(conn)

    case TransactionManager.get_by_id(id, org_id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{error: %{code: "not_found", message: "Transaction not found"}})

      tx ->
        conn |> put_status(200) |> json(%{transaction: serialize_full(tx)})
    end
  end

  @doc "GET /v1/transactions"
  def index(conn, params) do
    org_id = get_org_id(conn)
    opts = build_filter_opts(params)
    {transactions, total} = TransactionManager.list(org_id, opts)

    json(conn, %{
      transactions: Enum.map(transactions, &serialize_transaction/1),
      meta: %{
        total: total,
        limit: Keyword.get(opts, :limit, 20),
        offset: Keyword.get(opts, :offset, 0)
      }
    })
  end

  @doc "POST /v1/transactions/:id/retry-invoice"
  def retry_invoice(conn, %{"id" => id}) do
    org_id = get_org_id(conn)

    case TransactionManager.get_by_id(id, org_id) do
      %{status: :invoice_pending_manual} = tx ->
        {:ok, tx} = TransactionManager.transition(tx, :invoicing)
        conn |> put_status(202) |> json(%{status: tx.status, message: "SII submission re-queued"})

      nil ->
        conn
        |> put_status(404)
        |> json(%{error: %{code: "not_found", message: "Transaction not found"}})

      tx ->
        conn
        |> put_status(422)
        |> json(%{
          error: %{
            code: "invalid_status",
            message: "Transaction is in status '#{tx.status}', not 'invoice_pending_manual'"
          }
        })
    end
  end

  @doc "PUT /v1/transactions/:id/workflow-result"
  def workflow_result(conn, %{"id" => id} = params) do
    org_id = get_org_id(conn)

    case TransactionManager.get_by_id(id, org_id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{error: %{code: "not_found", message: "Transaction not found"}})

      tx ->
        workflow = %{status: params["status"], details: params["details"]}
        updated_metadata = Map.merge(tx.metadata || %{}, %{workflow_result: workflow})

        {:ok, tx} =
          tx
          |> Transaction.changeset(%{metadata: updated_metadata})
          |> Repo.update()

        conn |> put_status(200) |> json(%{transaction: serialize_transaction(tx)})
    end
  end

  # -- Private helpers --

  defp get_org_id(conn) do
    case conn.assigns[:org_id] do
      nil -> raise "No org_id in connection. Ensure authentication plugs are running."
      org_id -> org_id
    end
  end

  defp build_filter_opts(params) do
    []
    |> maybe_add(:status, params["status"])
    |> maybe_add(:from, parse_date(params["from"]))
    |> maybe_add(:to, parse_date(params["to"]))
    |> maybe_add(:limit, parse_int(params["limit"], 20))
    |> maybe_add(:offset, parse_int(params["offset"], 0))
  end

  defp maybe_add(opts, _key, nil), do: opts
  defp maybe_add(opts, key, value), do: Keyword.put(opts, key, value)

  defp parse_date(nil), do: nil

  defp parse_date(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp parse_int(nil, default), do: default

  defp parse_int(str, default) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> default
    end
  end

  defp serialize_transaction(tx) do
    %{
      id: tx.id,
      status: tx.status,
      amount: tx.amount,
      currency: tx.currency,
      card_last4: tx.card_last4,
      card_brand: tx.card_brand,
      product_id: tx.product_id,
      created_at: tx.inserted_at,
      authorized_at: tx.authorized_at,
      completed_at: tx.completed_at
    }
  end

  defp serialize_full(tx) do
    base = serialize_transaction(tx)

    base
    |> Map.put(:acquirer_tx_id, tx.acquirer_tx_id)
    |> Map.put(:metadata, tx.metadata)
    |> Map.put(:timeline, build_timeline(tx))
    |> Map.put(:updated_at, tx.updated_at)
  end

  defp build_timeline(tx) do
    events = [%{status: "pending", at: tx.inserted_at}]

    events =
      if tx.authorized_at do
        events ++ [%{status: "authorized", at: tx.authorized_at}]
      else
        events
      end

    if tx.completed_at do
      events ++ [%{status: "completed", at: tx.completed_at}]
    else
      events
    end
  end
end
