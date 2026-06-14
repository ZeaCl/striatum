defmodule StriatumWeb.CortexController do
  use StriatumWeb, :controller

  alias Striatum.CortexAdapter

  @doc "POST /v1/metered-billing"
  def create_billing_cycle(conn, params) do
    org_id = conn.assigns[:org_id]

    case CortexAdapter.create_billing_cycle(org_id, params) do
      {:ok, cycle} ->
        conn
        |> put_status(202)
        |> json(%{
          billing_cycle_id: cycle.id,
          status: cycle.status,
          estimated_charge: cycle.charged_amount_cents,
          billing_period_start: cycle.billing_period_start,
          billing_period_end: cycle.billing_period_end
        })

      {:error, :duplicate_period} ->
        conn
        |> put_status(409)
        |> json(%{
          error: %{
            code: "duplicate_period",
            message: "Billing cycle already exists for this period"
          }
        })

      {:error, _changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: %{code: "validation_error", message: "Invalid billing cycle data"}})
    end
  end

  @doc "GET /v1/metered-billing/cycles"
  def list_cycles(conn, _params) do
    org_id = conn.assigns[:org_id]

    cycles = CortexAdapter.list_cycles(org_id)

    json(conn, %{
      cycles:
        Enum.map(cycles, fn c ->
          %{
            id: c.id,
            status: c.status,
            total_tokens: c.total_tokens,
            total_api_calls: c.total_api_calls,
            charged_amount_cents: c.charged_amount_cents,
            billing_period_start: c.billing_period_start,
            billing_period_end: c.billing_period_end,
            transaction_id: c.transaction_id,
            created_at: c.inserted_at
          }
        end)
    })
  end
end
