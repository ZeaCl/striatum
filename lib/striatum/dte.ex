defmodule Striatum.DTE do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "dtes" do
    field :transaction_id, :binary_id
    field :folio, :integer
    field :sii_status, Ecto.Enum, values: [:pending, :accepted, :rejected], default: :pending
    field :sii_xml, :string
    field :pdf_url, :string
    field :sii_error_code, :string
    field :retry_count, :integer, default: 0
    field :submitted_at, :utc_datetime_usec
    field :accepted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(dte, attrs) do
    dte
    |> cast(attrs, [
      :transaction_id,
      :folio,
      :sii_status,
      :sii_xml,
      :pdf_url,
      :sii_error_code,
      :retry_count,
      :submitted_at,
      :accepted_at
    ])
    |> validate_required([:transaction_id, :folio])
    |> unique_constraint(:transaction_id)
  end
end
