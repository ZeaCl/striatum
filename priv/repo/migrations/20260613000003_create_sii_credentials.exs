defmodule Striatum.Repo.Migrations.CreateSiiCredentials do
  use Ecto.Migration

  def change do
    create table(:sii_credentials, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :rut, :string, null: false
      add :certificate_encrypted, :text
      add :private_key_encrypted, :text
      add :certificate_password_encrypted, :string
      add :branch_code, :string, default: "1"
      add :current_folio, :integer
      add :max_folio, :integer
      add :certificate_expires_at, :utc_datetime_usec
      add :is_active, :boolean, default: true

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:sii_credentials, [:organization_id])
  end
end
