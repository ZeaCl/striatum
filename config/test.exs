import Config

config :striatum, Striatum.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "striatum_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online()

config :striatum, StriatumWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4087],
  secret_key_base:
    "test-secret-key-base-minimum-64-chars-long-for-testing-only-not-secure-testing",
  server: false

config :logger, :console, level: :warning

config :striatum, :run_migrations, false
