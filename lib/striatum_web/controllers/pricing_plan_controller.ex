defmodule StriatumWeb.PricingPlanController do
  use StriatumWeb, :controller

  alias Striatum.{Repo, PricingPlan}
  import Ecto.Query

  @doc "GET /v1/pricing-plans"
  def index(conn, _params) do
    org_id = conn.assigns[:org_id]

    plans =
      Repo.all(
        from p in PricingPlan,
          where: p.organization_id == ^org_id,
          order_by: [desc: p.inserted_at]
      )

    json(conn, %{
      pricing_plans:
        Enum.map(plans, fn p ->
          %{
            id: p.id,
            name: p.name,
            base_monthly_cents: p.base_monthly_cents,
            per_token_rate_micro_cents: p.per_token_rate_micro_cents,
            per_api_call_rate_cents: p.per_api_call_rate_cents,
            tier_thresholds: p.tier_thresholds,
            is_active: p.is_active,
            created_at: p.inserted_at
          }
        end)
    })
  end

  @doc "POST /v1/pricing-plans"
  def create(conn, params) do
    org_id = conn.assigns[:org_id]

    # Deactivate existing active plans
    from(p in PricingPlan,
      where: p.organization_id == ^org_id,
      where: p.is_active == true
    )
    |> Repo.update_all(set: [is_active: false])

    %PricingPlan{}
    |> PricingPlan.changeset(%{
      organization_id: org_id,
      name: params["name"] || "Default Plan",
      base_monthly_cents: params["base_monthly_cents"] || 0,
      per_token_rate_micro_cents: params["per_token_rate_micro_cents"] || 0,
      per_api_call_rate_cents: params["per_api_call_rate_cents"] || 0,
      tier_thresholds: params["tier_thresholds"] || %{},
      is_active: true
    })
    |> Repo.insert()
    |> case do
      {:ok, plan} ->
        json(conn, %{
          id: plan.id,
          name: plan.name,
          base_monthly_cents: plan.base_monthly_cents,
          is_active: plan.is_active
        })

      {:error, _changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: %{code: "validation_error", message: "Invalid pricing plan"}})
    end
  end

  @doc "PUT /v1/pricing-plans/:id"
  def update(conn, %{"id" => id} = params) do
    org_id = conn.assigns[:org_id]

    case Repo.get_by(PricingPlan, id: id, organization_id: org_id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{error: %{code: "not_found", message: "Pricing plan not found"}})

      plan ->
        plan
        |> PricingPlan.changeset(%{
          name: params["name"] || plan.name,
          base_monthly_cents: params["base_monthly_cents"] || plan.base_monthly_cents,
          per_token_rate_micro_cents:
            params["per_token_rate_micro_cents"] || plan.per_token_rate_micro_cents,
          per_api_call_rate_cents:
            params["per_api_call_rate_cents"] || plan.per_api_call_rate_cents,
          tier_thresholds: params["tier_thresholds"] || plan.tier_thresholds,
          is_active: params["is_active"] || plan.is_active
        })
        |> Repo.update()
        |> case do
          {:ok, plan} ->
            json(conn, %{id: plan.id, name: plan.name, is_active: plan.is_active})

          {:error, _} ->
            conn |> put_status(422) |> json(%{error: %{code: "validation_error"}})
        end
    end
  end
end
