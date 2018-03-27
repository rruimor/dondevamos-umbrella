defmodule KiwiApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    KiwiApi.Supervisor.start_link()
  end
end
