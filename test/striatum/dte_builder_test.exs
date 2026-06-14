defmodule Striatum.DTEBuilderTest do
  use Striatum.DataCase

  alias Striatum.{DTEBuilder, TransactionManager, Repo, SiiCredential}
  import Ecto.Query

  @org_id "5fd11ea0-852c-44e5-aee1-a761ec76eaea"
  @branch_creds %{
    organization_id: @org_id,
    rut: "76000000-1",
    branch_code: "1",
    current_folio: 0,
    max_folio: 1000,
    is_active: true
  }

  setup do
    ensure_org()
    ensure_sii_creds()
    :ok
  end

  describe "build/1" do
    test "generates DTE for a transaction" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 29_990}, @org_id)

      {:ok, dte} = DTEBuilder.build(tx)

      assert dte.folio == 1
      assert dte.sii_status == :pending
      assert dte.sii_xml =~ "<DTE"
      assert dte.sii_xml =~ "<Folio>1</Folio>"
      assert dte.sii_xml =~ "<MntTotal>29990</MntTotal>"
      assert dte.pdf_url =~ "/dtes/"
    end

    test "increments folio sequentially" do
      {:ok, tx1} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {:ok, tx2} = TransactionManager.create(%{"amount" => 2000}, @org_id)

      {:ok, dte1} = DTEBuilder.build(tx1)
      {:ok, dte2} = DTEBuilder.build(tx2)

      assert dte1.folio == 1
      assert dte2.folio == 2
    end

    test "returns error when no SII credentials" do
      # Remove credentials
      Repo.delete_all(from c in SiiCredential, where: c.organization_id == ^@org_id)

      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      assert {:error, :no_credentials} = DTEBuilder.build(tx)

      # Restore credentials for other tests
      ensure_sii_creds()
    end

    test "includes customer rut from metadata" do
      {:ok, tx} =
        TransactionManager.create(
          %{
            "amount" => 1000,
            "metadata" => %{"customer_rut" => "11111111-1", "customer_name" => "Test Client"}
          },
          @org_id
        )

      {:ok, dte} = DTEBuilder.build(tx)
      assert dte.sii_xml =~ "111111111"
      assert dte.sii_xml =~ "Test Client"
    end

    test "defaults to consumidor final without customer metadata" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 5000}, @org_id)

      {:ok, dte} = DTEBuilder.build(tx)
      assert dte.sii_xml =~ "66666666-6"
      assert dte.sii_xml =~ "Consumidor Final"
    end

    test "rejects when out of folios" do
      # Set current folio to max
      Repo.get_by!(SiiCredential, organization_id: @org_id)
      |> Ecto.Changeset.change(%{current_folio: 1000, max_folio: 1000})
      |> Repo.update!()

      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      assert {:error, :out_of_folios} = DTEBuilder.build(tx)

      # Reset
      ensure_sii_creds()
    end
  end

  # -- Helpers --

  defp ensure_org do
    case Repo.get(Striatum.Organization, @org_id) do
      nil -> Repo.insert!(%Striatum.Organization{id: @org_id, name: "Test Org"})
      _ -> :ok
    end
  end

  defp ensure_sii_creds do
    case Repo.get_by(SiiCredential, organization_id: @org_id) do
      nil ->
        %SiiCredential{}
        |> SiiCredential.changeset(@branch_creds)
        |> Repo.insert!()

      existing ->
        existing
        |> Ecto.Changeset.change(%{current_folio: 0, max_folio: 1000})
        |> Repo.update!()
    end
  end
end
