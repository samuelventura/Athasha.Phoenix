defmodule Athasha.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :origin, :string
    field :token, :string
    field :confirmed, :boolean

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :origin, :token, :confirmed])
    |> validate_required([:email, :name, :password, :origin, :token])
    |> unique_constraint(:name)
    |> unique_constraint(:email)
  end
end
