defmodule StriatumWeb.Router do
  use StriatumWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug Corsica,
      origins: "*",
      allow_headers: ["content-type", "authorization", "x-api-key", "x-zea-org-id"]
  end

  pipeline :authenticated do
    plug StriatumWeb.Plugs.ApiKeyAuth
    plug StriatumWeb.Plugs.JWTAuth
  end

  scope "/", StriatumWeb do
    pipe_through :api

    get "/health", HealthController, :index
  end

  scope "/v1", StriatumWeb do
    pipe_through [:api, :authenticated]

    # Transactions
    get "/transactions", TransactionController, :index
    post "/transactions", TransactionController, :create
    get "/transactions/:id", TransactionController, :show
    post "/transactions/:id/retry-invoice", TransactionController, :retry_invoice

    # API Keys
    get "/api-keys", ApiKeyController, :index
    post "/api-keys", ApiKeyController, :create
    post "/api-keys/:id/revoke", ApiKeyController, :revoke

    # SII Credentials
    get "/sii-credentials", SiiController, :show
    put "/sii-credentials", SiiController, :update

    # Webhooks
    get "/webhooks/config", WebhookController, :show_config
    put "/webhooks/config", WebhookController, :update_config
    get "/webhooks/deliveries", WebhookController, :list_deliveries
    post "/webhooks/deliveries/:id/retry", WebhookController, :retry_delivery

    # Dashboard
    get "/dashboard/metrics", DashboardController, :metrics
    get "/dashboard/transactions", DashboardController, :transactions

    # Metered Billing (Cortex)
    post "/metered-billing", CortexController, :create_billing_cycle
    get "/metered-billing/cycles", CortexController, :list_cycles

    # Pricing Plans
    get "/pricing-plans", PricingPlanController, :index
    post "/pricing-plans", PricingPlanController, :create
    put "/pricing-plans/:id", PricingPlanController, :update

    # Cerebelum workflow callback
    put "/transactions/:id/workflow-result", TransactionController, :workflow_result

    # Sandbox
    get "/sandbox/scenarios", SandboxController, :index
    post "/sandbox/simulate", SandboxController, :simulate
  end
end
