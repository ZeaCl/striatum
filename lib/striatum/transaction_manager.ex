defmodule Striatum.TransactionManager do
  @moduledoc """
  Core module for transaction lifecycle management.

  Handles transaction creation, state transitions, idempotency,
  and dispatching to TransactionServer for async processing.
  """

  alias Striatum.{Repo, Transaction, ApiKey}
  import Ecto.Query

  @doc """
  Creates a new transaction and starts async authorization.

  Returns {:ok, transaction} on success, or {:error, reason} on failure.
  """
  @spec create(map(), String.t() | nil) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()} | {:error, :duplicate}
  def create(attrs, organization_id) do
    idempotency_key = Map.get(attrs, "idempotency_key")

    if idempotency_key do
      case get_by_idempotency(idempotency_key, organization_id) do
        %Transaction{} = existing -> {:ok, existing}
        nil -> do_create(attrs, organization_id)
        :error -> {:error, :duplicate}
      end
    else
      do_create(attrs, organization_id)
    end
  end

  @doc """
  Retrieves a transaction by ID, scoped to an organization.
  """
  @spec get_by_id(String.t(), String.t()) :: Transaction.t() | nil
  def get_by_id(id, organization_id) do
    Repo.get_by(Transaction, id: id, organization_id: organization_id)
  end

  @doc """
  Lists transactions for an organization with optional filters.
  """
  @spec list(String.t(), keyword()) :: {[Transaction.t()], integer()}
  def list(organization_id, opts \\ []) do
    base = from(t in Transaction, where: t.organization_id == ^organization_id)

    filtered =
      base
      |> filter_by_status(opts[:status])
      |> filter_by_date_range(opts[:from], opts[:to])
      |> order_by([t], desc: t.inserted_at)

    total = Repo.aggregate(filtered, :count, :id)

    page =
      filtered
      |> limit(^Keyword.get(opts, :limit, 20))
      |> offset(^Keyword.get(opts, :offset, 0))
      |> Repo.all()

    {page, total}
  end

  @doc """
  Transitions a transaction to a new status.
  Validates that the transition is legal.
  """
  @spec transition(Transaction.t(), atom()) ::
          {:ok, Transaction.t()} | {:error, :invalid_transition}
  def transition(transaction, new_status) do
    if valid_transition?(transaction.status, new_status) do
      attrs = transition_attrs(transaction, new_status)

      transaction
      |> Transaction.changeset(attrs)
      |> Repo.update()
    else
      {:error, :invalid_transition}
    end
  end

  @doc """
  Retrieves organization_id from an API key string.
  """
  @spec org_from_api_key(String.t()) :: {:ok, String.t(), [String.t()]} | :error
  def org_from_api_key(raw_key) when byte_size(raw_key) > 16 do
    key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode64()

    case Repo.get_by(ApiKey, key_hash: key_hash, is_active: true) do
      %ApiKey{organization_id: org_id, scopes: scopes} ->
        {:ok, org_id, scopes}

      nil ->
        :error
    end
  end

  # -- Private --

  defp do_create(attrs, org_id) do
    attrs = Map.put(attrs, "organization_id", org_id)

    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  defp get_by_idempotency(key, org_id) do
    case Repo.get_by(Transaction, idempotency_key: key, organization_id: org_id) do
      %Transaction{} = tx -> tx
      nil -> nil
    end
  rescue
    _ -> :error
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status), do: where(query, [t], t.status == ^status)

  defp filter_by_date_range(query, nil, nil), do: query
  defp filter_by_date_range(query, from, nil), do: where(query, [t], t.inserted_at >= ^from)
  defp filter_by_date_range(query, nil, to), do: where(query, [t], t.inserted_at <= ^to)

  defp filter_by_date_range(query, from, to),
    do: where(query, [t], t.inserted_at >= ^from and t.inserted_at <= ^to)

  @valid_transitions %{
    pending: [:authorized, :declined, :failed],
    authorized: [:invoicing, :completed_no_invoice],
    invoicing: [:completed, :invoice_failed, :invoice_pending_manual],
    invoice_pending_manual: [:invoicing, :invoice_failed],
    declined: [],
    failed: [],
    completed: [],
    completed_no_invoice: [],
    invoice_failed: []
  }

  defp valid_transition?(current, next_status) do
    next_status in Map.get(@valid_transitions, current, [])
  end

  defp transition_attrs(_transaction, :authorized) do
    %{status: :authorized, authorized_at: DateTime.utc_now()}
  end

  defp transition_attrs(_transaction, :completed) do
    %{status: :completed, completed_at: DateTime.utc_now()}
  end

  defp transition_attrs(_transaction, new_status) do
    %{status: new_status}
  end
end
