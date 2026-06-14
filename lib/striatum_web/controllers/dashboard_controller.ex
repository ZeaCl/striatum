defmodule StriatumWeb.DashboardController do
  use StriatumWeb, :controller

  alias Striatum.{Repo, Transaction}
  import Ecto.Query

  @doc "GET /v1/dashboard/metrics"
  def metrics(conn, _params) do
    org_id = conn.assigns[:org_id]

    total =
      Repo.aggregate(from(t in Transaction, where: t.organization_id == ^org_id), :count, :id)

    completed =
      Repo.aggregate(
        from(t in Transaction,
          where: t.organization_id == ^org_id,
          where: t.status == :completed
        ),
        :sum,
        :amount
      ) || 0

    success =
      from(t in Transaction,
        where: t.organization_id == ^org_id,
        where: t.status in [:completed, :completed_no_invoice]
      )
      |> Repo.aggregate(:count, :id)

    pending =
      from(t in Transaction,
        where: t.organization_id == ^org_id,
        where: t.status in [:pending, :authorized, :invoicing]
      )
      |> Repo.aggregate(:count, :id)

    failed_sii =
      from(t in Transaction,
        where: t.organization_id == ^org_id,
        where: t.status in [:invoice_failed, :invoice_pending_manual]
      )
      |> Repo.aggregate(:count, :id)

    success_rate = if total > 0, do: Float.round(success / total * 100, 1), else: 0.0

    json(conn, %{
      total_transactions: total,
      total_revenue_cents: completed,
      success_rate: success_rate,
      pending_count: pending,
      failed_sii_count: failed_sii
    })
  end

  @doc "GET /v1/dashboard/transactions"
  def transactions(conn, params) do
    org_id = conn.assigns[:org_id]
    format = params["format"]

    base =
      from(t in Transaction,
        where: t.organization_id == ^org_id,
        order_by: [desc: t.inserted_at],
        limit: 100
      )

    txs = Repo.all(base)

    if format == "csv" do
      csv = transactions_to_csv(txs)

      conn
      |> put_resp_header("content-type", "text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=transactions.csv")
      |> send_resp(200, csv)
    else
      json(conn, %{
        transactions:
          Enum.map(txs, fn tx ->
            %{
              id: tx.id,
              status: tx.status,
              amount: tx.amount,
              currency: tx.currency,
              card_last4: tx.card_last4,
              created_at: tx.inserted_at,
              completed_at: tx.completed_at
            }
          end)
      })
    end
  end

  defp transactions_to_csv(txs) do
    header = "id,status,amount,currency,card_last4,created_at,completed_at\n"

    rows =
      Enum.map_join(txs, "\n", fn tx ->
        "#{tx.id},#{tx.status},#{tx.amount},#{tx.currency},#{tx.card_last4},#{tx.inserted_at},#{tx.completed_at}"
      end)

    header <> rows <> "\n"
  end
end
