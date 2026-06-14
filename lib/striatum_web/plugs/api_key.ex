defmodule StriatumWeb.Plugs.ApiKeyAuth do
  @moduledoc """
  Validates API Key authentication via X-API-Key header.

  Uses SHA-256 hashing for key lookup. Sets `org_id` and `api_key_scopes`
  on the connection. Falls through if no API key is present.
  """
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "x-api-key") do
      [raw_key | _] when byte_size(raw_key) > 16 ->
        key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode64()

        case Striatum.Repo.get_by(Striatum.ApiKey, key_hash: key_hash, is_active: true) do
          %Striatum.ApiKey{organization_id: org_id, scopes: scopes} = key ->
            touch_last_used(key)

            conn
            |> assign(:org_id, org_id)
            |> assign(:api_key_scopes, scopes)
            |> assign(:authenticated, true)

          nil ->
            # No matching API key — fall through to JWT auth
            conn
        end

      _ ->
        conn
    end
  end

  defp touch_last_used(key) do
    Task.start(fn ->
      Ecto.Changeset.change(key, last_used_at: DateTime.utc_now())
      |> Striatum.Repo.update()
    end)
  end
end
