import Config

config :striatum,
  ecto_repos: [Striatum.Repo],
  namespace: Striatum

config :striatum, StriatumWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: StriatumWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Striatum.PubSub,
  live_view: [signing_salt: "striatum_salt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :joken,
  default_signer: nil

config :corsica,
  origins: "*",
  allow_headers: ["content-type", "authorization", "x-api-key", "x-zea-org-id"],
  allow_methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  max_age: 86400

config :striatum, Oban,
  repo: Striatum.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

if config_env() == :test do
  config :striatum, Oban, testing: :manual
end

import_config "#{config_env()}.exs"
