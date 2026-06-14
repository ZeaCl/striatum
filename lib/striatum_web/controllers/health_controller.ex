defmodule StriatumWeb.HealthController do
  use StriatumWeb, :controller

  def index(conn, _params) do
    db_status =
      case Ecto.Adapters.SQL.query(Striatum.Repo, "SELECT 1", []) do
        {:ok, _} -> "ok"
        _ -> "error"
      end

    json(conn, %{
      status: "ok",
      checks: %{
        database: db_status
      }
    })
  end
end
