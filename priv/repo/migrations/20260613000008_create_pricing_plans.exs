defmodule Striatum.Repo.Migrations.CreatePricingPlans do
  use Ecto.Migration

  def change do
    create table(:pricing_plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :base_monthly_cents, :integer
      add :per_token_rate_micro_cents, :integer
      add :per_api_call_rate_cents, :integer
      add :tier_thresholds, :map, default: %{}
      add :is_active, :boolean, default: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(:pricing_plans, [:organization_id])
  end
end
