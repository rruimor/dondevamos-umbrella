defmodule KiwiApi.ParamsHelper do
  def camelize_params(params) do
    params
    |> Enum.map(fn({k, v}) -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
    |> ProperCase.to_camel_case
  end
end