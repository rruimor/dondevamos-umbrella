defmodule KiwiApi.ParamsHelper do
  def camelize_params(params) do
    params
    |> Enum.map(fn({k, v}) -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
    |> ProperCase.to_camel_case
  end

  @doc """
    Kiwi API date format is "dd/mm/YYYY"
  """
  def format_date(date) do
    [date.day, date.month, date.year]
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join("/")
  end
end
