defmodule DondevamosWeb.TripControllerTest do
  use DondevamosWeb.ConnCase

  alias Dondevamos.Trips

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:trip) do
    {:ok, trip} = Trips.create_trip(@create_attrs)
    trip
  end

  describe "index" do
    test "lists all trips", %{conn: conn} do
      conn = get(conn, Routes.trip_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Trips"
    end
  end

  describe "new trip" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.trip_path(conn, :new))
      assert html_response(conn, 200) =~ "New Trip"
    end
  end

  describe "create trip" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.trip_path(conn, :create), trip: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.trip_path(conn, :show, id)

      conn = get(conn, Routes.trip_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Trip"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.trip_path(conn, :create), trip: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Trip"
    end
  end

  describe "edit trip" do
    setup [:create_trip]

    test "renders form for editing chosen trip", %{conn: conn, trip: trip} do
      conn = get(conn, Routes.trip_path(conn, :edit, trip))
      assert html_response(conn, 200) =~ "Edit Trip"
    end
  end

  describe "update trip" do
    setup [:create_trip]

    test "redirects when data is valid", %{conn: conn, trip: trip} do
      conn = put(conn, Routes.trip_path(conn, :update, trip), trip: @update_attrs)
      assert redirected_to(conn) == Routes.trip_path(conn, :show, trip)

      conn = get(conn, Routes.trip_path(conn, :show, trip))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, trip: trip} do
      conn = put(conn, Routes.trip_path(conn, :update, trip), trip: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Trip"
    end
  end

  describe "delete trip" do
    setup [:create_trip]

    test "deletes chosen trip", %{conn: conn, trip: trip} do
      conn = delete(conn, Routes.trip_path(conn, :delete, trip))
      assert redirected_to(conn) == Routes.trip_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.trip_path(conn, :show, trip))
      end
    end
  end

  defp create_trip(_) do
    trip = fixture(:trip)
    {:ok, trip: trip}
  end
end
