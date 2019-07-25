defmodule DondevamosWeb.Plugs.RequireAuth do
  import Plug.Conn
  use DondevamosWeb, :controller

  def init(_params) do

  end

  def call(conn, _params) do
    cond do
      _user = conn.assigns[:current_user] -> conn
      true -> conn
              |> put_flash(:error, "You must be logged in.")
              |> redirect(to: Routes.page_path(conn, :index))
              |> halt()
    end
  end
end