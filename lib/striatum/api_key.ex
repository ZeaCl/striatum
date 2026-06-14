defmodule Striatum.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "api_keys" do
    field :organization_id, :binary_id
    field :name, :string
    field :key_hash, :string
    field :key_prefix, :string, default: "zs_live_"
    field :scopes, {:array, :string}, default: []
    field :is_active, :boolean, default: true
    field :last_used_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [
      :organization_id,
      :name,
      :key_hash,
      :key_prefix,
      :scopes,
      :is_active,
      :last_used_at,
      :expires_at,
      :revoked_at
    ])
    |> validate_required([:organization_id, :name, :key_hash, :key_prefix])
  end
end
