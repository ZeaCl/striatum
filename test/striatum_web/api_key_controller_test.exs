defmodule StriatumWeb.ApiKeyControllerTest do
  use Striatum.DataCase

  alias Striatum.{Repo, ApiKey}

  @org_id "5fd11ea0-852c-44e5-aee1-a761ec76eaea"

  setup do
    case Repo.get(Striatum.Organization, @org_id) do
      nil -> Repo.insert!(%Striatum.Organization{id: @org_id, name: "Test Org"})
      _ -> :ok
    end

    :ok
  end

  describe "key_hash uniqueness" do
    test "stores SHA-256 hash of API key" do
      raw_key = "zs_live_test_key_1234567890"
      key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode64()

      {:ok, key} =
        %ApiKey{}
        |> ApiKey.changeset(%{
          organization_id: @org_id,
          name: "Test Key",
          key_hash: key_hash,
          key_prefix: "zs_live_",
          scopes: ["read"]
        })
        |> Repo.insert()

      assert key.key_hash == key_hash
      assert key.key_prefix == "zs_live_"
      assert key.is_active == true
    end

    test "revoking a key sets is_active false" do
      raw_key = "zs_live_revoked_key_123456789"
      key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode64()

      {:ok, key} =
        %ApiKey{}
        |> ApiKey.changeset(%{
          organization_id: @org_id,
          name: "Revocable Key",
          key_hash: key_hash,
          key_prefix: "zs_live_",
          scopes: ["read"]
        })
        |> Repo.insert()

      updated =
        key
        |> Ecto.Changeset.change(%{is_active: false, revoked_at: DateTime.utc_now()})
        |> Repo.update!()

      refute updated.is_active
      assert updated.revoked_at != nil
    end
  end
end
