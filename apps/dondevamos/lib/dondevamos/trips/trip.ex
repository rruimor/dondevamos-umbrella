defmodule Dondevamos.Trips.Trip do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dondevamos.Accounts.User

  schema "trips" do
    field :name, :string
#    field :user_id, :id
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
