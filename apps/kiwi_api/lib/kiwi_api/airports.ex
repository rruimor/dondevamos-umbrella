defmodule KiwiApi.Airports do
  import KiwiApi.Client, only: [ fetch!: 2 ]

  def by_location(location) do
    params = %{
      term: location,
      location_types: "airport",
      limit: 5
    }
    fetch!("/locations", params).body
  end
end