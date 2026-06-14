defmodule Striatum.CerebelumAdapter do
  @moduledoc """
  Adapter for Cerebelum — ZEA Workflow Engine integration.

  Sends signals to Cerebelum when payments are completed,
  triggering workflow activations (agent provisioning, resource allocation, etc.).
  """

  require Logger

  @doc """
  Sends a payment_completed signal to Cerebelum.

  This is called when a transaction reaches completed status.
  Cerebelum can then trigger workflows to provision resources.
  """
  def send_payment_completed(%Striatum.Transaction{} = tx) do
    cerebelum_url = Application.get_env(:striatum, :cerebelum_url, "http://cerebelum:4080")

    signal = %{
      type: "striatum.payment_completed",
      data: %{
        org_id: tx.organization_id,
        transaction_id: tx.id,
        amount: tx.amount,
        currency: tx.currency,
        product_id: tx.product_id,
        workflow_id: get_workflow_id(tx),
        metadata: tx.metadata
      }
    }

    case Req.post("#{cerebelum_url}/api/v1/signals", json: signal, receive_timeout: 5000) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("Cerebelum signal sent for transaction #{tx.id}")
        :ok

      {:ok, %{status: status}} ->
        Logger.warning("Cerebelum signal failed with status #{status} for tx #{tx.id}")
        {:error, :cerebelum_unavailable}

      {:error, reason} ->
        Logger.warning("Cerebelum signal error: #{inspect(reason)} for tx #{tx.id}")
        {:error, :cerebelum_unavailable}
    end
  end

  defp get_workflow_id(tx) do
    case tx.metadata do
      %{"workflow_id" => wf_id} when is_binary(wf_id) -> wf_id
      %{"cerebelum_workflow_id" => wf_id} when is_binary(wf_id) -> wf_id
      _ -> nil
    end
  end
end
