defmodule Striatum.Repo do
  use Ecto.Repo,
    otp_app: :striatum,
    adapter: Ecto.Adapters.Postgres
end
