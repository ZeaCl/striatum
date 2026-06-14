defmodule Striatum.Repo.Migrations.CreateSandboxScenarios do
  use Ecto.Migration

  def change do
    create table(:sandbox_scenarios, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :scenario, :string, null: false
      add :remaining_count, :integer
      add :expires_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:sandbox_scenarios, [:organization_id])
  end
end
