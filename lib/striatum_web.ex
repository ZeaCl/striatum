defmodule StriatumWeb do
  @moduledoc """
  The entrypoint for defining web interfaces, such as controllers, components,
  channels, and so on.
  """

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:json]

      import Plug.Conn
      alias StriatumWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
