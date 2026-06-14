defmodule Striatum.SandboxScenario do
  use Ecto.Schema
  import Ecto.Changeset

  @scenarios [:sii_timeout, :acquirer_decline, :partial_outage, :webhook_delay, :reset]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sandbox_scenarios" do
    field :organization_id, :binary_id
    field :scenario, Ecto.Enum, values: @scenarios
    field :remaining_count, :integer
    field :expires_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(scenario, attrs) do
    scenario
    |> cast(attrs, [:organization_id, :scenario, :remaining_count, :expires_at])
    |> validate_required([:organization_id, :scenario])
  end
end
