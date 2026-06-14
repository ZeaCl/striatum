defmodule Striatum.Jobs.WebhookDeliveryJob do
  @moduledoc """
  Oban job that delivers webhook events to organization endpoints.

  Retry with exponential backoff: 10s, 30s, 1m, 2m, 5m, 10m, 30m.
  Max 7 attempts. HTTP 410 Gone disables the endpoint permanently.
  """
  use Oban.Worker,
    queue: :webhook_delivery,
    max_attempts: 7

  alias Striatum.{Repo, WebhookDelivery, WebhookConfig}

  require Logger

  @impl true
  def perform(%Oban.Job{args: args, attempt: attempt}) do
    delivery_id = args["delivery_id"]
    delivery = Repo.get!(WebhookDelivery, delivery_id)

    cond do
      attempt > 6 ->
        Logger.error("All webhook delivery attempts exhausted for #{delivery_id}")
        mark_failed(delivery)
        :ok

      true ->
        do_deliver(delivery, args)
    end
  end

  @impl true
  def backoff(%Oban.Job{attempt: attempt}) do
    # 10s, 30s, 1m, 2m, 5m, 10m, 30m
    backoffs = [10, 30, 60, 120, 300, 600, 1800]
    Enum.at(backoffs, attempt - 1, 1800)
  end

  # -- Private --

  defp do_deliver(delivery, args) do
    url = args["url"]
    payload = args["payload"]
    signature = args["signature"]

    case Req.post(url,
           body: payload,
           headers: %{
             "content-type" => "application/json",
             "x-striatum-signature" => signature,
             "x-striatum-event" => args["event_type"]
           },
           receive_timeout: 10_000
         ) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        delivery
        |> Ecto.Changeset.change(%{
          succeeded: true,
          http_status: status,
          response_body: to_response_body(body),
          delivered_at: DateTime.utc_now(),
          next_retry_at: nil
        })
        |> Repo.update!()

        :ok

      {:ok, %{status: 410}} ->
        Logger.warning("Webhook endpoint returned 410 Gone — disabling for org")
        disable_endpoint(delivery)

        delivery
        |> Ecto.Changeset.change(%{
          http_status: 410,
          response_body: "Gone",
          succeeded: false
        })
        |> Repo.update!()

        :ok

      {:ok, %{status: status, body: body}} ->
        next_retry = compute_next_retry(delivery.attempt_count + 1)

        delivery
        |> Ecto.Changeset.change(%{
          attempt_count: delivery.attempt_count + 1,
          http_status: status,
          response_body: to_response_body(body),
          next_retry_at: next_retry
        })
        |> Repo.update!()

        {:error, "HTTP #{status}"}

      {:error, reason} ->
        next_retry = compute_next_retry(delivery.attempt_count + 1)

        delivery
        |> Ecto.Changeset.change(%{
          attempt_count: delivery.attempt_count + 1,
          http_status: 0,
          response_body: inspect(reason),
          next_retry_at: next_retry
        })
        |> Repo.update!()

        {:error, :timeout}
    end
  end

  defp mark_failed(delivery) do
    delivery
    |> Ecto.Changeset.change(%{
      succeeded: false,
      next_retry_at: nil
    })
    |> Repo.update!()
  end

  defp disable_endpoint(delivery) do
    tx = Repo.get!(Striatum.Transaction, delivery.transaction_id)
    org_id = tx.organization_id

    case Repo.get_by(WebhookConfig, organization_id: org_id) do
      nil -> :ok
      config -> config |> Ecto.Changeset.change(%{is_active: false}) |> Repo.update!()
    end
  end

  defp compute_next_retry(attempt) do
    backoffs = [10, 30, 60, 120, 300, 600, 1800]
    seconds = Enum.at(backoffs, attempt - 1, 1800)
    DateTime.add(DateTime.utc_now(), seconds, :second)
  end

  defp to_response_body(body) when is_binary(body), do: String.slice(body, 0, 1000)
  defp to_response_body(body), do: inspect(body) |> String.slice(0, 1000)
end
