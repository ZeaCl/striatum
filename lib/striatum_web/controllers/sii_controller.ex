defmodule StriatumWeb.SiiController do
  use StriatumWeb, :controller

  alias Striatum.{Repo, SiiCredential}

  @doc "GET /v1/sii-credentials"
  def show(conn, _params) do
    org_id = conn.assigns[:org_id]

    case Repo.get_by(SiiCredential, organization_id: org_id) do
      nil ->
        json(conn, %{configured: false})

      creds ->
        json(conn, %{
          configured: true,
          rut: creds.rut,
          branch_code: creds.branch_code,
          current_folio: creds.current_folio,
          max_folio: creds.max_folio,
          certificate_expires_at: creds.certificate_expires_at,
          is_active: creds.is_active,
          folios_remaining: (creds.max_folio || 0) - (creds.current_folio || 0)
        })
    end
  end

  @doc "PUT /v1/sii-credentials"
  def update(conn, params) do
    org_id = conn.assigns[:org_id]

    attrs = %{
      organization_id: org_id,
      rut: params["rut"],
      certificate_encrypted: encrypt(params["certificate"]),
      private_key_encrypted: encrypt(params["private_key"]),
      certificate_password_encrypted: encrypt(params["certificate_password"]),
      branch_code: params["branch_code"] || "1",
      max_folio: params["max_folio"],
      is_active: true
    }

    case Repo.get_by(SiiCredential, organization_id: org_id) do
      nil ->
        %SiiCredential{}
        |> SiiCredential.changeset(attrs)
        |> Repo.insert()

      existing ->
        existing
        |> SiiCredential.changeset(attrs)
        |> Repo.update()
    end
    |> case do
      {:ok, creds} ->
        json(conn, %{
          configured: true,
          rut: creds.rut,
          branch_code: creds.branch_code,
          current_folio: creds.current_folio,
          max_folio: creds.max_folio
        })

      {:error, _changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: %{code: "validation_error", message: "Invalid SII credentials"}})
    end
  end

  defp encrypt(nil), do: nil

  defp encrypt(value) when is_binary(value) do
    key = get_encryption_key()
    # AES-256-GCM encryption (simplified for mock — in production use proper crypto)
    "enc:#{Base.encode64(:crypto.hash(:sha256, key <> value))}"
  end

  defp get_encryption_key do
    Application.get_env(:striatum, :encryption_key, "dev-encryption-key-32-bytes-long!!")
  end
end
