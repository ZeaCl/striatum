defmodule StriatumWeb.WebhookController do
  use StriatumWeb, :controller

  alias Striatum.{Repo, WebhookConfig, WebhookDelivery}
  import Ecto.Query

  @doc "GET /v1/webhooks/config"
  def show_config(conn, _params) do
    org_id = conn.assigns[:org_id]

    case Repo.get_by(WebhookConfig, organization_id: org_id) do
      nil -> json(conn, %{configured: false})
      config -> json(conn, %{configured: true, url: config.url, is_active: config.is_active})
    end
  end

  @doc "PUT /v1/webhooks/config"
  def update_config(conn, params) do
    org_id = conn.assigns[:org_id]
    url = params["url"]
    secret = params["secret"] || generate_secret()

    if is_nil(url) || url == "" do
      conn
      |> put_status(422)
      |> json(%{error: %{code: "invalid_url", message: "URL is required"}})
    else
      attrs = %{organization_id: org_id, url: url, secret: secret, is_active: true}

      case Repo.get_by(WebhookConfig, organization_id: org_id) do
        nil ->
          %WebhookConfig{}
          |> WebhookConfig.changeset(attrs)
          |> Repo.insert()

        existing ->
          existing
          |> WebhookConfig.changeset(attrs)
          |> Repo.update()
      end
      |> case do
        {:ok, config} ->
          json(conn, %{configured: true, url: config.url, is_active: config.is_active})

        {:error, _changeset} ->
          conn
          |> put_status(422)
          |> json(%{error: %{code: "validation_error", message: "Invalid webhook config"}})
      end
    end
  end

  @doc "GET /v1/webhooks/deliveries"
  def list_deliveries(conn, _params) do
    org_id = conn.assigns[:org_id]

    query =
      from d in WebhookDelivery,
        join: t in Striatum.Transaction,
        on: d.transaction_id == t.id,
        where: t.organization_id == ^org_id,
        order_by: [desc: d.inserted_at],
        limit: 50

    deliveries = Repo.all(query)

    json(conn, %{
      deliveries:
        Enum.map(deliveries, fn d ->
          %{
            id: d.id,
            transaction_id: d.transaction_id,
            event_type: d.event_type,
            attempt_count: d.attempt_count,
            http_status: d.http_status,
            succeeded: d.succeeded,
            delivered_at: d.delivered_at,
            next_retry_at: d.next_retry_at
          }
        end)
    })
  end

  @doc "POST /v1/webhooks/deliveries/:id/retry"
  def retry_delivery(conn, %{"id" => id}) do
    org_id = conn.assigns[:org_id]

    delivery =
      from(d in WebhookDelivery,
        join: t in Striatum.Transaction,
        on: d.transaction_id == t.id,
        where: d.id == ^id and t.organization_id == ^org_id
      )
      |> Repo.one()

    case delivery do
      nil ->
        conn
        |> put_status(404)
        |> json(%{error: %{code: "not_found", message: "Delivery not found"}})

      delivery ->
        config = Repo.get_by(WebhookConfig, organization_id: org_id)

        if config && config.is_active do
          tx = Repo.get!(Striatum.Transaction, delivery.transaction_id)

          payload =
            Striatum.WebhookDispatcher.build_payload(tx, delivery.event_type, delivery.event_id)

          signature = Striatum.WebhookDispatcher.sign(payload, config.secret)

          %{
            delivery_id: delivery.id,
            url: config.url,
            payload: payload,
            signature: signature,
            event_type: delivery.event_type
          }
          |> Striatum.Jobs.WebhookDeliveryJob.new()
          |> Oban.insert()

          conn |> put_status(202) |> json(%{message: "Webhook delivery re-queued"})
        else
          conn
          |> put_status(422)
          |> json(%{error: %{code: "no_config", message: "No active webhook config"}})
        end
    end
  end

  defp generate_secret do
    :crypto.strong_rand_bytes(32) |> Base.encode64(padding: false)
  end
end
