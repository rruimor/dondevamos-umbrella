defmodule Dondevamos.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dondevamos.Trips.Trip

  schema "users" do
    field :avatar_url, :string
    field :email, :string
    field :provider, :string
    field :token, :string
    field :first_name, :string
    field :last_name, :string
    has_many :trips, Trip

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :provider, :token, :avatar_url, :first_name, :last_name])
    |> validate_required([:email, :provider, :token, :avatar_url, :first_name, :last_name])
  end
end
