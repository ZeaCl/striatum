defmodule Striatum.Repo.Migrations.CreateWebhookDeliveries do
  use Ecto.Migration

  def change do
    create table(:webhook_deliveries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :transaction_id, references(:transactions, type: :binary_id, on_delete: :delete_all), null: false
      add :event_type, :string, null: false
      add :event_id, :binary_id, null: false
      add :url, :string, null: false
      add :attempt_count, :integer, default: 1
      add :http_status, :integer
      add :response_body, :text
      add :succeeded, :boolean, default: false
      add :delivered_at, :utc_datetime_usec
      add :next_retry_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:webhook_deliveries, [:transaction_id])
    create index(:webhook_deliveries, [:next_retry_at])
  end
end
