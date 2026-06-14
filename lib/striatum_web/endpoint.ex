defmodule StriatumWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :striatum

  plug Corsica, origins: Application.compile_env(:corsica, :origins)

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head

  plug StriatumWeb.Router
end
