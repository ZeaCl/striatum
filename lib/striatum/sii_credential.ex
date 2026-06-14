defmodule Striatum.SiiCredential do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sii_credentials" do
    field :organization_id, :binary_id
    field :rut, :string
    field :certificate_encrypted, :string
    field :private_key_encrypted, :string
    field :certificate_password_encrypted, :string
    field :branch_code, :string, default: "1"
    field :current_folio, :integer
    field :max_folio, :integer
    field :certificate_expires_at, :utc_datetime_usec
    field :is_active, :boolean, default: true

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(creds, attrs) do
    creds
    |> cast(attrs, [
      :organization_id,
      :rut,
      :certificate_encrypted,
      :private_key_encrypted,
      :certificate_password_encrypted,
      :branch_code,
      :current_folio,
      :max_folio,
      :certificate_expires_at,
      :is_active
    ])
    |> validate_required([:organization_id, :rut])
    |> unique_constraint(:organization_id)
  end
end
