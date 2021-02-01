defmodule Athasha.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :password, :string
      add :origin, :string
      add :token, :string
      add :confirmed, :boolean, default: false

      timestamps()
    end

    create unique_index(:users, [:name])
    create unique_index(:users, [:email])

    create table(:sessions) do
      add :name, :string
      add :email, :string
      add :origin, :string

      timestamps()
    end
  end
end
