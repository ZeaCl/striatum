defmodule Striatum.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [
    :pending,
    :authorized,
    :declined,
    :invoicing,
    :completed,
    :invoice_failed,
    :failed,
    :completed_no_invoice,
    :invoice_pending_manual
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :organization_id, :binary_id
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :amount, :integer
    field :currency, :string, default: "CLP"
    field :card_last4, :string
    field :card_brand, :string
    field :acquirer_tx_id, :string
    field :acquirer_response, :map
    field :metadata, :map, default: %{}
    field :idempotency_key, :string
    field :billing_cycle_id, :binary_id
    field :product_id, :string
    field :authorized_at, :utc_datetime_usec
    field :completed_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :organization_id,
      :status,
      :amount,
      :currency,
      :card_last4,
      :card_brand,
      :acquirer_tx_id,
      :acquirer_response,
      :metadata,
      :idempotency_key,
      :billing_cycle_id,
      :product_id,
      :authorized_at,
      :completed_at
    ])
    |> validate_required([:organization_id, :amount, :currency])
    |> validate_number(:amount, greater_than: 0)
    |> unique_constraint(:idempotency_key)
  end
end
