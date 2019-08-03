defmodule FlightsAggregator.CombinedFlights do
  @derive Jason.Encoder
  defstruct origins: [], destination: nil, flights: [], departure_date: nil, total_price: 0.0, average_price: 0.0

  def total_price(flights) do
    flights |> Enum.reduce(0.0, fn x, acc -> x["price"] + acc end)
  end

  def average_price(flights) do
    (flights |> total_price) / (flights |> length)
  end
end