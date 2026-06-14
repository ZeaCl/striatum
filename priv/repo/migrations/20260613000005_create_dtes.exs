defmodule Striatum.Repo.Migrations.CreateDtes do
  use Ecto.Migration

  def change do
    create table(:dtes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :transaction_id, references(:transactions, type: :binary_id, on_delete: :restrict), null: false
      add :folio, :integer, null: false
      add :sii_status, :string, null: false, default: "pending"
      add :sii_xml, :text
      add :pdf_url, :string
      add :sii_error_code, :string
      add :retry_count, :integer, default: 0
      add :submitted_at, :utc_datetime_usec
      add :accepted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:dtes, [:transaction_id])
    create index(:dtes, [:sii_status])
  end
end
