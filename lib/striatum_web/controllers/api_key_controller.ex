defmodule StriatumWeb.ApiKeyController do
  use StriatumWeb, :controller

  alias Striatum.{Repo, ApiKey}
  import Ecto.Query

  @prefix "zs_live_"

  @doc "GET /v1/api-keys"
  def index(conn, _params) do
    org_id = conn.assigns[:org_id]

    keys =
      Repo.all(
        from k in ApiKey, where: k.organization_id == ^org_id, order_by: [desc: k.inserted_at]
      )

    json(conn, %{
      api_keys:
        Enum.map(keys, fn k ->
          %{
            id: k.id,
            name: k.name,
            key_prefix: k.key_prefix,
            scopes: k.scopes,
            is_active: k.is_active,
            last_used_at: k.last_used_at,
            created_at: k.inserted_at,
            expires_at: k.expires_at
          }
        end)
    })
  end

  @doc "POST /v1/api-keys"
  def create(conn, params) do
    org_id = conn.assigns[:org_id]
    name = params["name"] || "Unnamed Key"
    scopes = params["scopes"] || ["read"]

    raw_key = @prefix <> (:crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false))
    key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode64()

    {:ok, key} =
      %ApiKey{}
      |> ApiKey.changeset(%{
        organization_id: org_id,
        name: name,
        key_hash: key_hash,
        key_prefix: @prefix,
        scopes: scopes,
        is_active: true
      })
      |> Repo.insert()

    json(conn, %{
      api_key: raw_key,
      id: key.id,
      name: key.name,
      prefix: @prefix,
      scopes: key.scopes,
      message: "Store this key securely. It will not be shown again."
    })
  end

  @doc "POST /v1/api-keys/:id/revoke"
  def revoke(conn, %{"id" => id}) do
    org_id = conn.assigns[:org_id]

    case Repo.get_by(ApiKey, id: id, organization_id: org_id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{error: %{code: "not_found", message: "API key not found"}})

      key ->
        key
        |> Ecto.Changeset.change(%{is_active: false, revoked_at: DateTime.utc_now()})
        |> Repo.update!()

        json(conn, %{id: key.id, revoked: true, message: "API key revoked"})
    end
  end
end
