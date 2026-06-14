defmodule Striatum.TransactionSupervisor do
  @moduledoc """
  DynamicSupervisor that manages TransactionServer processes.

  Each transaction gets its own supervised GenServer.
  If a process crashes, it is restarted from the last persisted state.
  """
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a new TransactionServer under supervision.
  """
  def start_child(%Striatum.Transaction{} = transaction) do
    child_spec = %{
      id: {:transaction_server, transaction.id},
      start: {Striatum.TransactionServer, :start_link, [transaction]},
      restart: :transient,
      shutdown: 5_000
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
