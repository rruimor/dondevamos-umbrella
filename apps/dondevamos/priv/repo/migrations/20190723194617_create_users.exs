defmodule Dondevamos.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :provider, :string
      add :token, :string
      add :avatar_url, :string

      timestamps()
    end

  end
end
