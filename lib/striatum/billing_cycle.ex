defmodule Striatum.BillingCycle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "billing_cycles" do
    field :organization_id, :binary_id
    field :pricing_plan_id, :binary_id

    field :status, Ecto.Enum,
      values: [:pending, :processing, :completed, :payment_failed],
      default: :pending

    field :total_tokens, :integer, default: 0
    field :total_api_calls, :integer, default: 0
    field :charged_amount_cents, :integer
    field :transaction_id, :binary_id
    field :billing_period_start, :date
    field :billing_period_end, :date

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [
      :organization_id,
      :pricing_plan_id,
      :status,
      :total_tokens,
      :total_api_calls,
      :charged_amount_cents,
      :transaction_id,
      :billing_period_start,
      :billing_period_end
    ])
    |> validate_required([:organization_id, :billing_period_start, :billing_period_end])
  end
end
