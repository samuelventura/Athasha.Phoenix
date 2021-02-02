defmodule Athasha.Repo.Migrations.AuthSchema do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :password, :string
      add :origin, :string
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

    create table(:emails) do
      add :email, :string
      add :title, :string
      add :body, :string
      add :sent, :boolean, default: false

      timestamps()
    end

    create table(:tokens) do
      add :token, :string
      add :origin, :string
      add :payload, :string
      add :done, :boolean, default: false
      add :user_id, references(:users)

      timestamps()
    end
  end
end
