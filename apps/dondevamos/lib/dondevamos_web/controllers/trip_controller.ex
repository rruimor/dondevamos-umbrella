defmodule DondevamosWeb.TripController do
  use DondevamosWeb, :controller

  alias Dondevamos.Trips
  alias Dondevamos.Trips.Trip
  alias Dondevamos.Accounts

  def index(conn, _params) do
    trips = conn.assigns[:current_user].trips
    render(conn, "index.html", trips: trips)
  end

  def new(conn, _params) do
    changeset = Trips.change_trip(%Trip{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"trip" => trip_params}) do
    trip_params =
      trip_params
      |> Map.put("user", conn.assigns[:current_user])
    case Trips.create_trip(trip_params) do
      {:ok, trip} ->
        conn
        |> put_flash(:info, "Trip created successfully.")
        |> redirect(to: Routes.trip_path(conn, :show, trip))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    trip = Trips.get_trip!(id)
    render(conn, "show.html", trip: trip)
  end

  def edit(conn, %{"id" => id}) do
    trip = Trips.get_trip!(id)
    changeset = Trips.change_trip(trip)
    render(conn, "edit.html", trip: trip, changeset: changeset)
  end

  def update(conn, %{"id" => id, "trip" => trip_params}) do
    trip = Trips.get_trip!(id)

    case Trips.update_trip(trip, trip_params) do
      {:ok, trip} ->
        conn
        |> put_flash(:info, "Trip updated successfully.")
        |> redirect(to: Routes.trip_path(conn, :show, trip))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", trip: trip, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    trip = Trips.get_trip!(id)
    {:ok, _trip} = Trips.delete_trip(trip)

    conn
    |> put_flash(:info, "Trip deleted successfully.")
    |> redirect(to: Routes.trip_path(conn, :index))
  end
end
