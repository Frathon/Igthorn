defmodule UiWeb do
  @moduledoc false

  def controller do
    quote do
      use Phoenix.Controller, namespace: UiWeb

      import Plug.Conn
      import UiWeb.Gettext
      alias UiWeb.Router.Helpers, as: Routes
      import Phoenix.LiveView.Controller, only: [live_render: 3]
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/ui_web/templates",
        namespace: UiWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import UiWeb.ErrorHelpers
      import UiWeb.Gettext
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]
      alias UiWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import UiWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
