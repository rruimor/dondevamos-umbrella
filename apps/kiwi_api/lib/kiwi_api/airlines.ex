defmodule KiwiApi.Airlines do
  import KiwiApi.Client, only: [ fetch!: 2 ]

  def all do
    fetch!("/airlines", %{}).body
  end

  def by_code(code) do
    all() |> 
    Enum.find(fn(x) -> x["id"] == code end)
  end
end