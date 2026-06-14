defmodule Striatum.TransactionManagerTest do
  use Striatum.DataCase

  alias Striatum.{TransactionManager, Repo, Organization}

  @org_id "5fd11ea0-852c-44e5-aee1-a761ec76eaea"

  setup do
    # Ensure test org exists
    case Repo.get(Organization, @org_id) do
      nil ->
        %Organization{id: @org_id, name: "Test Org"}
        |> Repo.insert!()

      _ ->
        :ok
    end

    :ok
  end

  describe "create/2" do
    test "creates a pending transaction with valid params" do
      params = %{
        "amount" => 29_990,
        "currency" => "CLP",
        "card_token" => "tok_visa_test",
        "description" => "Test payment",
        "product_id" => "prod_test"
      }

      {:ok, tx} = TransactionManager.create(params, @org_id)

      assert tx.status == :pending
      assert tx.amount == 29_990
      assert tx.currency == "CLP"
      assert tx.organization_id == @org_id
    end

    test "rejects zero amount" do
      params = %{"amount" => 0, "currency" => "CLP"}

      {:error, changeset} = TransactionManager.create(params, @org_id)
      assert "must be greater than 0" in errors_on(changeset).amount
    end

    test "rejects negative amount" do
      params = %{"amount" => -100, "currency" => "CLP"}

      {:error, changeset} = TransactionManager.create(params, @org_id)
      assert errors_on(changeset).amount != nil
    end

    test "idempotency key prevents duplicate creation" do
      params = %{
        "amount" => 1000,
        "currency" => "CLP",
        "idempotency_key" => "idem_test_001"
      }

      {:ok, tx1} = TransactionManager.create(params, @org_id)
      {:ok, tx2} = TransactionManager.create(params, @org_id)

      assert tx1.id == tx2.id
      assert tx1.status == tx2.status
    end

    test "defaults currency to CLP" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 500}, @org_id)
      assert tx.currency == "CLP"
    end

    test "stores metadata" do
      params = %{
        "amount" => 1000,
        "currency" => "CLP",
        "metadata" => %{"agent_id" => "ag_123", "email" => "test@example.com"}
      }

      {:ok, tx} = TransactionManager.create(params, @org_id)
      assert tx.metadata["agent_id"] == "ag_123"
      assert tx.metadata["email"] == "test@example.com"
    end
  end

  describe "get_by_id/2" do
    test "returns transaction for correct org" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      found = TransactionManager.get_by_id(tx.id, @org_id)
      assert found.id == tx.id
    end

    test "returns nil for wrong org" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      found = TransactionManager.get_by_id(tx.id, "00000000-0000-0000-0000-000000000000")
      assert is_nil(found)
    end

    test "returns nil for non-existent id" do
      found = TransactionManager.get_by_id("00000000-0000-0000-0000-000000000000", @org_id)
      assert is_nil(found)
    end
  end

  describe "list/2" do
    test "returns transactions for org" do
      {:ok, tx1} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {:ok, tx2} = TransactionManager.create(%{"amount" => 2000}, @org_id)

      {txs, total} = TransactionManager.list(@org_id)
      assert total >= 2
      ids = Enum.map(txs, & &1.id)
      assert tx1.id in ids
      assert tx2.id in ids
    end

    test "filters by status" do
      {:ok, _} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {txs, _} = TransactionManager.list(@org_id, status: "pending")
      assert length(txs) > 0
      Enum.each(txs, fn tx -> assert tx.status == :pending end)
    end

    test "empty list for different org" do
      {:ok, _} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {txs, total} = TransactionManager.list("00000000-0000-0000-0000-000000000000")
      assert total == 0
      assert txs == []
    end
  end

  describe "transition/2" do
    test "allows pending -> authorized" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {:ok, tx} = TransactionManager.transition(tx, :authorized)
      assert tx.status == :authorized
      assert tx.authorized_at != nil
    end

    test "allows pending -> declined" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {:ok, tx} = TransactionManager.transition(tx, :declined)
      assert tx.status == :declined
    end

    test "rejects invalid transition" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      assert {:error, :invalid_transition} = TransactionManager.transition(tx, :completed)
    end

    test "prevents transition from terminal state" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {:ok, tx} = TransactionManager.transition(tx, :declined)
      assert {:error, :invalid_transition} = TransactionManager.transition(tx, :authorized)
    end

    test "completes full happy path" do
      {:ok, tx} = TransactionManager.create(%{"amount" => 1000}, @org_id)
      {:ok, tx} = TransactionManager.transition(tx, :authorized)
      assert tx.status == :authorized
      {:ok, tx} = TransactionManager.transition(tx, :invoicing)
      assert tx.status == :invoicing
      {:ok, tx} = TransactionManager.transition(tx, :completed)
      assert tx.status == :completed
      assert tx.completed_at != nil
    end
  end
end
