defmodule DondevamosWeb.PageController do
  use DondevamosWeb, :controller
  plug Ueberauth

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
