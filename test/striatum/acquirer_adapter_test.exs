defmodule Striatum.AcquirerAdapterTest do
  use ExUnit.Case

  alias Striatum.AcquirerAdapter.Mock

  describe "authorize/1" do
    test "approves normal payment" do
      result =
        Mock.authorize(%{
          amount: 1000,
          card_token: "tok_visa_1234",
          currency: "CLP",
          metadata: %{}
        })

      assert {:ok, result} = result
      assert result.acquirer_tx_id =~ "mock_tx_"
      assert result.card_last4 == "1234"
      assert result.card_brand == "visa"
    end

    test "declines when amount modulo 13 == 0" do
      assert {:error, :declined} =
               Mock.authorize(%{
                 amount: 1300,
                 card_token: "tok_visa_1234",
                 currency: "CLP",
                 metadata: %{}
               })
    end

    test "declines with decline token" do
      assert {:error, :declined} =
               Mock.authorize(%{
                 amount: 1000,
                 card_token: "tok_decline",
                 currency: "CLP",
                 metadata: %{}
               })
    end

    test "timeout when amount modulo 17 == 0" do
      assert {:error, :timeout} =
               Mock.authorize(%{
                 amount: 1700,
                 card_token: "tok_visa_1234",
                 currency: "CLP",
                 metadata: %{}
               })
    end

    test "invalid with specific token" do
      assert {:error, :invalid_token} =
               Mock.authorize(%{
                 amount: 1000,
                 card_token: "tok_invalid",
                 currency: "CLP",
                 metadata: %{}
               })
    end

    test "invalid with negative amount" do
      assert {:error, :invalid_token} =
               Mock.authorize(%{
                 amount: -100,
                 card_token: "tok_visa_1234",
                 currency: "CLP",
                 metadata: %{}
               })
    end

    test "detects mastercard brand" do
      {:ok, result} =
        Mock.authorize(%{amount: 1000, card_token: "tok_mc_5678", currency: "CLP", metadata: %{}})

      assert result.card_brand == "mastercard"
    end

    test "detects amex brand" do
      {:ok, result} =
        Mock.authorize(%{
          amount: 1000,
          card_token: "tok_amex_9012",
          currency: "CLP",
          metadata: %{}
        })

      assert result.card_brand == "amex"
    end
  end
end
