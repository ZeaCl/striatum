defmodule Striatum.SIIAdapter.Mock do
  @moduledoc """
  Mock implementation of SIIAdapter for development and testing.

  Rules:
  - Amount even → accepted
  - Amount odd → rejected
  - Amount modulo 19 == 0 → timeout
  - Sandbox scenarios override these rules
  """
  @behaviour Striatum.SIIAdapter

  require Logger
  import Ecto.Query

  @impl true
  def submit_dte(params) do
    org_id = Map.get(params, :organization_id, "unknown")

    case get_scenario_override(org_id) do
      :timeout ->
        Logger.debug(
          "SII mock: returning timeout due to active sandbox scenario for org #{org_id}"
        )

        {:error, :timeout}

      nil ->
        do_submit(params)
    end
  end

  @impl true
  def check_certificate_expiry(_credentials) do
    # Mock: certificate expires in 365 days
    {:ok, 365}
  end

  @impl true
  def get_available_folios(_credentials) do
    # Mock: 500 folios available out of 1000
    {:ok, 500, 1000}
  end

  # -- Private --

  defp do_submit(params) do
    amount = params.monto

    cond do
      rem(amount, 19) == 0 ->
        {:error, :timeout}

      rem(amount, 2) == 0 ->
        track_id = "sii_track_#{:crypto.strong_rand_bytes(8) |> Base.hex_encode32(case: :lower)}"
        {:ok, %{folio: params.folio, sii_track_id: track_id}}

      true ->
        {:error, :rejected}
    end
  end

  defp get_scenario_override(org_id) do
    case Ecto.UUID.cast(org_id) do
      {:ok, uuid} -> do_get_scenario_override(uuid)
      :error -> nil
    end
  end

  defp do_get_scenario_override(org_id) do
    now = DateTime.utc_now()

    query =
      from s in Striatum.SandboxScenario,
        where: s.organization_id == ^org_id,
        where: s.scenario in ^[:sii_timeout, :partial_outage],
        where: s.remaining_count > 0 or is_nil(s.remaining_count),
        where: is_nil(s.expires_at) or s.expires_at > ^now

    case Striatum.Repo.one(query) do
      %{scenario: "sii_timeout"} -> :timeout
      %{scenario: "partial_outage"} -> if :rand.uniform(2) == 1, do: :timeout, else: nil
      nil -> nil
    end
  end
end
