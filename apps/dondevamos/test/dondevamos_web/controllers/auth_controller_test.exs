defmodule DondevamosWeb.AuthControllerTest do
  use DondevamosWeb.ConnCase
  alias Dondevamos.Accounts

  @ueberauth_auth %{
    credentials: %{token: "egaegaegaege"},
    info: %{
      email: "yolo@molo.com",
      first_name: "Yolo",
      last_name: "Molo",
      image: "https://yolo.molo.com"
    },
    provider: :google
  }

  test "redirects user to Google for authentication", %{conn: conn} do
    conn = get(conn, "/auth/google")
    assert redirected_to(conn, 302)
  end

#  test "creates user from Google information", %{conn: conn} do
#    conn =
#      conn
#      |> assign(:ueberauth_auth, @ueberauth_auth)
#      |> get(Routes.auth_path(conn, :callback, "google"))
#
#    users = Accounts.list_users()
#    assert users |> Enum.count == 1
#    assert get_flash(conn, :info) == "Successfully authenticated."
#  end
end
