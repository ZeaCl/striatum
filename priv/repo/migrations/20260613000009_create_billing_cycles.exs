defmodule Striatum.Repo.Migrations.CreateBillingCycles do
  use Ecto.Migration

  def change do
    create table(:billing_cycles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :restrict), null: false
      add :pricing_plan_id, references(:pricing_plans, type: :binary_id, on_delete: :restrict)
      add :status, :string, null: false, default: "pending"
      add :total_tokens, :integer, default: 0
      add :total_api_calls, :integer, default: 0
      add :charged_amount_cents, :integer
      add :transaction_id, references(:transactions, type: :binary_id, on_delete: :nilify_all)
      add :billing_period_start, :date, null: false
      add :billing_period_end, :date, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:billing_cycles, [:organization_id, :billing_period_start, :billing_period_end])
    create index(:billing_cycles, [:organization_id])
  end
end
