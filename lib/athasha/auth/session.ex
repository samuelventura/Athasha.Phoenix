defmodule Athasha.Auth.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :email, :string
    field :name, :string
    field :origin, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :origin])
    |> validate_required([:email, :name, :origin])
  end
end
