defmodule Striatum.AcquirerAdapter do
  @moduledoc """
  Behaviour for payment acquirer/gateway adapters.

  Implementations handle tokenized card authorization, capture, and refund.
  Multiple adapters can coexist (Transbank, MercadoPago, Stripe, etc.).
  """

  @type token :: String.t()
  @type amount :: integer()
  @type currency :: String.t()

  @type authorize_params :: %{
          card_token: token(),
          amount: amount(),
          currency: currency(),
          description: String.t() | nil,
          metadata: map()
        }

  @type authorize_result ::
          {:ok, %{acquirer_tx_id: String.t(), card_last4: String.t(), card_brand: String.t()}}
          | {:error, :declined}
          | {:error, :timeout}
          | {:error, :invalid_token}

  @callback authorize(authorize_params()) :: authorize_result()
  @callback capture(acquirer_tx_id :: String.t(), amount :: amount()) :: :ok | {:error, atom()}
  @callback refund(acquirer_tx_id :: String.t(), amount :: amount()) :: :ok | {:error, atom()}
end
