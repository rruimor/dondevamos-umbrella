defmodule DondevamosApiWeb.FlightsController do
  use DondevamosApiWeb, :controller

  def flights(conn, params) do
    departure_date = Date.from_iso8601!(params["departure_date"])
    results = FlightsAggregator.find_combined_flights(params["origin"], departure_date)
    IO.inspect results

    json(conn, %{data: results})
  end
end
