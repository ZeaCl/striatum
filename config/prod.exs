import Config

config :striatum, StriatumWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4086],
  secret_key_base: {System, :get_env, ["SECRET_KEY_BASE"]},
  server: true

config :striatum, Striatum.Repo,
  url: {System, :get_env, ["DATABASE_URL"]},
  pool_size: 20,
  socket_options: [:inet6]

config :logger, :console, level: :info
