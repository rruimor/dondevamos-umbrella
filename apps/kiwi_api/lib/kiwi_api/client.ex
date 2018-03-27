defmodule KiwiApi.Client do
  use HTTPoison.Base

  def process_url(url) do
    "https://api.skypicker.com" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> ProperCase.to_snake_case
  end

  def fetch!(url, params) do
    get!(url, [], params: params)
  end
end