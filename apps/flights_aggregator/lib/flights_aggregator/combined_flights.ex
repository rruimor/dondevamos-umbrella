defmodule FlightsAggregator.CombinedFlights do
  defstruct origins: [], destination: nil, flights: []

  def total_price(combined_flights) do
    combined_flights.flights |> Enum.reduce(0.0, fn x, acc -> x["price"] + acc end)
  end

  def average_price(combined_flights) do
    (combined_flights |> total_price) / (combined_flights.flights |> length)
  end
end