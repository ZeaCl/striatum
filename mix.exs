defmodule Striatum.MixProject do
  use Mix.Project

  def project do
    [
      app: :striatum,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: [
        striatum: [include_executables_for: [:unix], applications: [runtime_tools: :permanent]]
      ],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Striatum.Application, []}
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:plug_cowboy, "~> 2.7"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:joken, "~> 2.6"},
      {:req, "~> 0.5"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19"},
      {:corsica, "~> 2.1"},
      {:oban, "~> 2.18"},
      {:dns_cluster, "~> 0.2"}
    ]
  end

  defp aliases do
    [
      precommit: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def cli do
    [preferred_envs: [precommit: :test]]
  end
end
