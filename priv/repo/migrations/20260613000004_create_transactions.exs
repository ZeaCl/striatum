defmodule Striatum.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :restrict), null: false
      add :status, :string, null: false, default: "pending"
      add :amount, :integer, null: false
      add :currency, :string, null: false, default: "CLP"
      add :card_last4, :string
      add :card_brand, :string
      add :acquirer_tx_id, :string
      add :acquirer_response, :map
      add :metadata, :map, default: %{}
      add :idempotency_key, :string
      add :billing_cycle_id, :binary_id
      add :product_id, :string
      add :authorized_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:transactions, [:organization_id, :status])
    create index(:transactions, [:billing_cycle_id])
    create unique_index(:transactions, [:idempotency_key])
    create index(:transactions, [:inserted_at])

    create constraint(:transactions, :valid_status,
      check: "status IN ('pending','authorized','declined','invoicing','completed','invoice_failed','failed','completed_no_invoice','invoice_pending_manual')"
    )
  end
end
