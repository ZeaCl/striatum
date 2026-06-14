defmodule Striatum.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    # Run migrations on startup in production (best-effort)
    if Application.get_env(:striatum, :run_migrations, true) do
      try do
        Striatum.Release.migrate()
      rescue
        _ -> Logger.warning("Migrations skipped — database not available")
      end
    end

    children = [
      Striatum.Repo,
      {Striatum.TransactionSupervisor, []},
      {DNSCluster, query: Application.get_env(:striatum, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Striatum.PubSub},
      StriatumWeb.Endpoint,
      {Oban, Application.get_env(:striatum, Oban)}
    ]

    opts = [strategy: :one_for_one, name: Striatum.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
