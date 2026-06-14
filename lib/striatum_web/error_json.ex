defmodule StriatumWeb.ErrorJSON do
  @moduledoc """
  Renders JSON error responses.
  """

  def render(template, _assigns) do
    %{error: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def call(conn, :not_found) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(
      404,
      Jason.encode!(%{error: %{code: "not_found", message: "Not found"}})
    )
  end

  def call(conn, :internal_server_error) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(
      500,
      Jason.encode!(%{error: %{code: "internal_error", message: "Internal server error"}})
    )
  end
end
