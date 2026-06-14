defmodule Striatum.WebhookConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "webhook_configs" do
    field :organization_id, :binary_id
    field :url, :string
    field :secret, :string
    field :is_active, :boolean, default: true

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [:organization_id, :url, :secret, :is_active])
    |> validate_required([:organization_id, :url, :secret])
    |> validate_format(:url, ~r/^https?:\/\//)
    |> unique_constraint(:organization_id)
  end
end
