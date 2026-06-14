defmodule Striatum.WebhookDelivery do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "webhook_deliveries" do
    field :transaction_id, :binary_id
    field :event_type, :string
    field :event_id, :binary_id
    field :url, :string
    field :attempt_count, :integer, default: 1
    field :http_status, :integer
    field :response_body, :string
    field :succeeded, :boolean, default: false
    field :delivered_at, :utc_datetime_usec
    field :next_retry_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(delivery, attrs) do
    delivery
    |> cast(attrs, [
      :transaction_id,
      :event_type,
      :event_id,
      :url,
      :attempt_count,
      :http_status,
      :response_body,
      :succeeded,
      :delivered_at,
      :next_retry_at
    ])
    |> validate_required([:transaction_id, :event_type, :event_id, :url])
  end
end
