defmodule KiwiApi.Flights do
  import KiwiApi.Client, only: [ fetch!: 2 ]
  import KiwiApi.ParamsHelper, only: [ camelize_params: 1 ]

  @doc """
    date_from: "dd/mm/YYYY"
  """
  def search(fly_from, to, date_from, date_to, extra_params \\ %{}) do
    params = %{
      fly_from: fly_from,
      to: to,
      date_from: date_from,
      date_to: date_to
    }
    params = Map.merge(params, extra_params)
    fetch!("/flights", params |> camelize_params()).body["data"]
  end

  def search(params) do
    fetch!("/flights", params |> camelize_params()).body["data"]
  end
end