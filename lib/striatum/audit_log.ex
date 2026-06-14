defmodule Striatum.AuditLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "audit_logs" do
    field :organization_id, :binary_id
    field :actor_id, :binary_id
    field :actor_type, :string
    field :action, :string
    field :resource_type, :string
    field :resource_id, :binary_id
    field :details, :map
    field :ip_address, :string

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :organization_id,
      :actor_id,
      :actor_type,
      :action,
      :resource_type,
      :resource_id,
      :details,
      :ip_address
    ])
    |> validate_required([:organization_id, :action])
  end
end
