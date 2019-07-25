defmodule DondevamosWeb.Plugs.SetUser do
  import Plug.Conn
  alias Dondevamos.Accounts

  def init(_opts) do

  end

  def call(conn, _repo) do
    user_id = get_session(conn, "id")

    cond do
      user = conn.assigns[:current_user] -> assign(conn, :current_user, user)
      user = user_id && Accounts.get_user!(user_id) -> assign(conn, :current_user, user)
      true -> assign(conn, :current_user, nil)
    end
  end
end