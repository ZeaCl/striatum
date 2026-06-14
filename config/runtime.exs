import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: postgresql://user:pass@host:5432/striatum_prod
      """

  config :striatum, Striatum.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "20")),
    socket_options: [:inet6]

  config :striatum, StriatumWeb.Endpoint,
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT", "4086"))
    ],
    secret_key_base: {System, :get_env, ["SECRET_KEY_BASE"]},
    check_origin: false,
    server: true

  thalamus_url = System.get_env("THALAMUS_URL", "http://thalamus:4000")

  config :striatum, :thalamus,
    url: thalamus_url,
    jwks_url: "#{thalamus_url}/.well-known/jwks.json"

  encryption_key_raw = System.get_env("ENCRYPTION_KEY", "dev-encryption-key-32-bytes-long!!")
  config :striatum, :encryption_key, encryption_key_raw

  config :striatum, :run_migrations, false
end
