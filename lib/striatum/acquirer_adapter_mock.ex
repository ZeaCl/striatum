defmodule Striatum.AcquirerAdapter.Mock do
  @moduledoc """
  Mock implementation of AcquirerAdapter for development and testing.

  Rules:
  - Amount < 0 → :invalid_token
  - Amount modulo 13 == 0 → :declined
  - Amount modulo 17 == 0 → :timeout
  - Everything else → approved
  """
  @behaviour Striatum.AcquirerAdapter

  @impl true
  def authorize(%{amount: amount, card_token: token, currency: _currency, metadata: _metadata}) do
    cond do
      token == "tok_decline" or rem(amount, 13) == 0 ->
        {:error, :declined}

      token == "tok_timeout" or rem(amount, 17) == 0 ->
        {:error, :timeout}

      token == "tok_invalid" or amount < 0 ->
        {:error, :invalid_token}

      true ->
        tx_id = "mock_tx_#{:crypto.strong_rand_bytes(8) |> Base.hex_encode32(case: :lower)}"

        {:ok,
         %{
           acquirer_tx_id: tx_id,
           card_last4:
             String.slice(token, -4, 4) |> then(fn s -> if s == "", do: "4242", else: s end),
           card_brand: detect_brand(token)
         }}
    end
  end

  @impl true
  def capture(_acquirer_tx_id, _amount), do: :ok

  @impl true
  def refund(_acquirer_tx_id, _amount), do: :ok

  defp detect_brand("tok_visa" <> _), do: "visa"
  defp detect_brand("tok_mc" <> _), do: "mastercard"
  defp detect_brand("tok_amex" <> _), do: "amex"
  defp detect_brand(_), do: "visa"
end
