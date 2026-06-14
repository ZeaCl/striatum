defmodule Striatum.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :actor_id, :binary_id
      add :actor_type, :string
      add :action, :string, null: false
      add :resource_type, :string
      add :resource_id, :binary_id
      add :details, :map
      add :ip_address, :inet

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:audit_logs, [:organization_id, :inserted_at])
    create index(:audit_logs, [:resource_type, :resource_id])
  end
end
