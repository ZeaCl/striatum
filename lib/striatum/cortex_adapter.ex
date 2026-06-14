defmodule Striatum.CortexAdapter do
  @moduledoc """
  Adapter for Cortex — ZEA AI Gateway integration.

  Handles metered billing: receives consumption reports from Cortex,
  calculates charges based on pricing plans, and triggers automatic payments.
  """

  alias Striatum.{Repo, BillingCycle, PricingPlan, WebhookDispatcher}
  import Ecto.Query

  require Logger

  @doc """
  Creates a billing cycle from a Cortex consumption report.

  Returns {:ok, billing_cycle} or {:error, reason}.
  """
  def create_billing_cycle(org_id, params) do
    billing_period_start = parse_date(params["billing_period_start"])
    billing_period_end = parse_date(params["billing_period_end"])

    # Check for duplicate billing period
    existing =
      Repo.one(
        from bc in BillingCycle,
          where: bc.organization_id == ^org_id,
          where: bc.billing_period_start == ^billing_period_start,
          where: bc.billing_period_end == ^billing_period_end
      )

    if existing do
      {:error, :duplicate_period}
    else
      pricing_plan =
        Repo.one(
          from pp in PricingPlan,
            where: pp.organization_id == ^org_id,
            where: pp.is_active == true
        )

      total_tokens = params["total_tokens"] || 0
      total_api_calls = params["total_api_calls"] || 0

      charged_amount =
        if pricing_plan do
          calculate_charge(pricing_plan, total_tokens, total_api_calls)
        else
          0
        end

      %BillingCycle{}
      |> BillingCycle.changeset(%{
        organization_id: org_id,
        pricing_plan_id: pricing_plan && pricing_plan.id,
        status: :pending,
        total_tokens: total_tokens,
        total_api_calls: total_api_calls,
        charged_amount_cents: charged_amount,
        billing_period_start: billing_period_start,
        billing_period_end: billing_period_end
      })
      |> Repo.insert()
    end
  end

  @doc """
  Lists billing cycles for an organization.
  """
  def list_cycles(org_id) do
    Repo.all(
      from bc in BillingCycle,
        where: bc.organization_id == ^org_id,
        order_by: [desc: bc.inserted_at]
    )
  end

  @doc """
  Processes a billing cycle: autoriza el cobro automático y emite webhook.
  """
  def process_billing_cycle(%BillingCycle{} = cycle) do
    if cycle.charged_amount_cents > 0 do
      # Create an automatic transaction for the charge
      {:ok, tx} =
        Striatum.TransactionManager.create(
          %{
            "amount" => cycle.charged_amount_cents,
            "currency" => "CLP",
            "card_token" => "tok_auto_billing",
            "description" =>
              "Cobro automático período #{cycle.billing_period_start}/#{cycle.billing_period_end}",
            "product_id" => "metered_billing",
            "idempotency_key" => "billing_#{cycle.id}"
          },
          cycle.organization_id
        )

      # Link transaction to billing cycle
      cycle
      |> Ecto.Changeset.change(%{transaction_id: tx.id, status: :processing})
      |> Repo.update!()

      # Dispatch webhook
      WebhookDispatcher.dispatch(tx, "billing.cycle_completed")
    end

    {:ok, cycle}
  end

  # -- Private --

  defp calculate_charge(plan, tokens, api_calls) do
    base = plan.base_monthly_cents || 0
    token_charge = div(tokens * (plan.per_token_rate_micro_cents || 0), 10_000)
    api_charge = api_calls * (plan.per_api_call_rate_cents || 0)

    # Apply tier thresholds if configured
    total = base + token_charge + api_charge

    case plan.tier_thresholds do
      %{"tiers" => tiers} when is_list(tiers) ->
        apply_tiers(total, tokens, tiers)

      _ ->
        total
    end
  end

  defp apply_tiers(total, _tokens, []) do
    total
  end

  defp apply_tiers(total, tokens, [tier | rest]) do
    threshold = Map.get(tier, "threshold", 0)
    rate = Map.get(tier, "rate_micro_cents", 0)

    if tokens > threshold do
      overage = tokens - threshold
      overage_charge = div(overage * rate, 10_000)
      total + overage_charge
    else
      apply_tiers(total, tokens, rest)
    end
  end

  defp parse_date(nil), do: Date.utc_today()
  defp parse_date(str) when is_binary(str), do: Date.from_iso8601!(str)
end
