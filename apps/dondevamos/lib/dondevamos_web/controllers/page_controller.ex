defmodule DondevamosWeb.PageController do
  use DondevamosWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def yolo(conn, _params) do
    render(conn, "index.html")
  end
end
