defmodule FlightsAggregator do
  @moduledoc """
  Documentation for FlightsAggregator.
  """

  alias FlightsAggregator.CombinedFlights

  @doc """
  It returns a list of `FlightsAggregator.CombinedFlights` given a list of `origins` and a `departure_date`.

  `origins` must be a list of airport ids or IATA code.
  `departure_date` format must be "dd/mm/YYYY".

  ## Examples

      iex> FlightsAggregator.find_combined_flights(~w(SZZ SXF), ~D[2019-08-01])
      [
        %FlightsAggregator.CombinedFlights{
          destination: "Oslo",
          flights: [ .. ],
          origins: [SZZ, SXF],
          departure_date: ~D[2019-08-01]
        }
      ]

  """
  def find_combined_flights(origins, departure_date) do
    origins
    |> Enum.flat_map(&(fetch_flights(&1, departure_date)))
    |> Enum.group_by(fn flight -> flight["city_to"] end)
    |> Enum.filter(fn {_destination, flights} -> flights |> length == origins |> length end)
    |> Enum.map(
         fn {destination, flights} ->
           %CombinedFlights{
             origins: origins,
             destination: destination,
             flights: flights,
             departure_date: departure_date,
             total_price: flights |> CombinedFlights.total_price,
             average_price: flights |> CombinedFlights.average_price
           }
         end
       )
    |> Enum.sort(&((&1.total_price) < (&2.total_price) ))
  end

  defp fetch_flights(origin, departure_date) do
    KiwiApi.Flights.search(
      %{
        fly_from: origin,
        fly_to: "",
        date_from: departure_date,
        date_to: departure_date
      },
      %{
        oneforcity: 1,
        direct_flights: 1
      }
    )
  end
end
