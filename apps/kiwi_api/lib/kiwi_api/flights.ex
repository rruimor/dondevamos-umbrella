defmodule KiwiApi.Flights do
  import KiwiApi.Client, only: [ fetch!: 2 ]
  import KiwiApi.ParamsHelper

  def search(%{fly_from: fly_from, fly_to: fly_to, date_from: date_from, date_to: date_to}, extra_params \\ %{}) do
    params = %{
      fly_from: fly_from,
      to: fly_to,
      date_from: date_from |> format_date,
      date_to: date_to |> format_date,
      partner: "picky"
    }
    params = Map.merge(params, extra_params)
    fetch!("/flights", params |> camelize_params()).body["data"]
  end
end