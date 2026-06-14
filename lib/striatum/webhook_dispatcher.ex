defmodule Striatum.WebhookDispatcher do
  @moduledoc """
  Builds and delivers signed webhook events to organization endpoints.

  Webhooks use HMAC-SHA256 signatures with timestamp-based verification
  to prevent replay attacks.
  """

  alias Striatum.{Repo, Transaction, WebhookConfig, WebhookDelivery}
  alias Striatum.Jobs.WebhookDeliveryJob

  require Logger

  @doc """
  Dispatches a webhook event for a transaction.

  The event is queued as an Oban job for async delivery with retry logic.
  """
  @spec dispatch(Transaction.t(), atom() | String.t()) ::
          {:ok, WebhookDelivery.t()} | {:error, atom()}
  def dispatch(%Transaction{} = transaction, event_type) do
    org_id = transaction.organization_id

    case Repo.get_by(WebhookConfig, organization_id: org_id, is_active: true) do
      nil ->
        Logger.debug("No active webhook config for org #{org_id}")
        {:error, :no_config}

      config ->
        event_id = Ecto.UUID.generate()
        payload = build_payload(transaction, event_type, event_id)
        signature = sign(payload, config.secret)

        delivery =
          %WebhookDelivery{}
          |> WebhookDelivery.changeset(%{
            transaction_id: transaction.id,
            event_type: to_string(event_type),
            event_id: event_id,
            url: config.url,
            attempt_count: 1
          })
          |> Repo.insert!()

        # Enqueue async delivery
        %{
          delivery_id: delivery.id,
          url: config.url,
          payload: payload,
          signature: signature,
          event_type: to_string(event_type)
        }
        |> WebhookDeliveryJob.new()
        |> Oban.insert()

        {:ok, delivery}
    end
  end

  @doc """
  Builds the webhook payload JSON.
  """
  def build_payload(%Transaction{} = transaction, event_type, event_id) do
    %{
      event_id: event_id,
      event_type: to_string(event_type),
      created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      data: %{
        transaction_id: transaction.id,
        organization_id: transaction.organization_id,
        status: to_string(transaction.status),
        amount: transaction.amount,
        currency: transaction.currency,
        metadata: transaction.metadata
      }
    }
    |> Jason.encode!()
  end

  @doc """
  Generates HMAC-SHA256 signature for a webhook payload.

  Format: t={timestamp},v1={hex_signature}
  """
  def sign(payload, secret) when is_binary(payload) and is_binary(secret) do
    timestamp = System.os_time(:second)
    signed_payload = "#{timestamp}.#{payload}"
    signature = :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)
    "t=#{timestamp},v1=#{signature}"
  end

  @doc """
  Verifies a webhook signature.
  """
  def verify_signature(payload, signature_header, secret, tolerance_seconds \\ 300)
      when is_binary(payload) and is_binary(signature_header) and is_binary(secret) do
    with {:ok, timestamp, sig} <- parse_header(signature_header),
         true <- within_tolerance?(timestamp, tolerance_seconds) do
      expected =
        :crypto.mac(:hmac, :sha256, secret, "#{timestamp}.#{payload}")
        |> Base.encode16(case: :lower)

      Plug.Crypto.secure_compare(sig, expected)
    else
      _ -> false
    end
  end

  # -- Private --

  defp parse_header(header) do
    parts = String.split(header, ",", parts: 2)

    with [t_part, v1_part] <- parts,
         "t=" <> t_str <- String.trim(t_part),
         "v1=" <> sig <- String.trim(v1_part),
         {ts, ""} <- Integer.parse(t_str) do
      {:ok, ts, sig}
    else
      _ -> :error
    end
  end

  defp within_tolerance?(timestamp, tolerance) do
    now = System.os_time(:second)
    abs(now - timestamp) <= tolerance
  end
end
