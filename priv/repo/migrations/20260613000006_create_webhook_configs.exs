defmodule Striatum.Repo.Migrations.CreateWebhookConfigs do
  use Ecto.Migration

  def change do
    create table(:webhook_configs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :url, :string, null: false
      add :secret, :string, null: false
      add :is_active, :boolean, default: true

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:webhook_configs, [:organization_id])
  end
end
