defmodule Striatum.WebhookDispatcherTest do
  use ExUnit.Case

  alias Striatum.WebhookDispatcher

  describe "sign/2" do
    test "generates HMAC-SHA256 signature" do
      payload = ~s({"event":"test"})
      secret = "whsec_test_123"

      signature = WebhookDispatcher.sign(payload, secret)

      assert signature =~ "t="
      assert signature =~ ",v1="
    end
  end

  describe "verify_signature/4" do
    test "verifies valid signature" do
      payload = ~s({"event":"test"})
      secret = "whsec_test_123"
      signature = WebhookDispatcher.sign(payload, secret)

      assert WebhookDispatcher.verify_signature(payload, signature, secret)
    end

    test "rejects invalid signature" do
      payload = ~s({"event":"test"})
      secret = "whsec_test_123"
      fake_sig = "t=9999999999,v1=deadbeef"

      refute WebhookDispatcher.verify_signature(payload, fake_sig, secret)
    end

    test "rejects signature with wrong secret" do
      payload = ~s({"event":"test"})
      secret = "whsec_test_123"
      signature = WebhookDispatcher.sign(payload, secret)

      refute WebhookDispatcher.verify_signature(payload, signature, "wrong_secret")
    end

    test "rejects tampered payload" do
      payload = ~s({"event":"test"})
      secret = "whsec_test_123"
      signature = WebhookDispatcher.sign(payload, secret)

      refute WebhookDispatcher.verify_signature(~s({"event":"hacked"}), signature, secret)
    end

    test "rejects malformed header" do
      refute WebhookDispatcher.verify_signature("test", "garbage", "secret")
    end
  end

  describe "build_payload/3" do
    test "builds JSON payload with event metadata" do
      tx = %Striatum.Transaction{
        id: "tx_123",
        organization_id: "org_456",
        status: :completed,
        amount: 29_990,
        currency: "CLP",
        metadata: %{"key" => "value"}
      }

      payload = WebhookDispatcher.build_payload(tx, "transaction.completed", "evt_001")
      decoded = Jason.decode!(payload)

      assert decoded["event_id"] == "evt_001"
      assert decoded["event_type"] == "transaction.completed"
      assert decoded["data"]["transaction_id"] == "tx_123"
      assert decoded["data"]["amount"] == 29_990
    end
  end
end
