defmodule Striatum.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :email, :string
    field :default_currency, :string, default: "CLP"

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(org, attrs) do
    org
    |> cast(attrs, [:id, :name, :email, :default_currency])
    |> validate_required([:name])
  end
end
