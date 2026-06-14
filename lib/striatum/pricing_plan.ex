defmodule Striatum.PricingPlan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pricing_plans" do
    field :organization_id, :binary_id
    field :name, :string
    field :base_monthly_cents, :integer
    field :per_token_rate_micro_cents, :integer
    field :per_api_call_rate_cents, :integer
    field :tier_thresholds, :map, default: %{}
    field :is_active, :boolean, default: true

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [
      :organization_id,
      :name,
      :base_monthly_cents,
      :per_token_rate_micro_cents,
      :per_api_call_rate_cents,
      :tier_thresholds,
      :is_active
    ])
    |> validate_required([:organization_id, :name])
  end
end
