defmodule KiwiApi.Client do
  use HTTPoison.Base
  use Retry

  def process_url(url) do
    "https://api.skypicker.com" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> ProperCase.to_snake_case
  end

  def fetch!(url, params) do
    retry with: exponential_backoff() |> cap(1_000) |> expiry(1_000) do
      get!(url, [], params: params)
    after
      result -> result
    else
      error -> error
    end
  end
end