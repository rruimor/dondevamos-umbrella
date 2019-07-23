defmodule Dondevamos.Repo do
  use Ecto.Repo,
    otp_app: :dondevamos,
    adapter: Ecto.Adapters.Postgres
end
