import Config

config :striatum, Striatum.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "striatum_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :striatum, StriatumWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4086],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base:
    "dev-striatum-secret-key-base-minimum-64-chars-long-for-development-only-not-secure",
  watchers: []

config :logger, :console, level: :debug

config :striatum, :run_migrations, false
