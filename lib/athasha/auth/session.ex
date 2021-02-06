defmodule Athasha.Auth.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    belongs_to :user, Athasha.Auth.User
    field :email, :string
    field :name, :string
    field :origin, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :origin])
    |> validate_required([:email, :name, :origin])
  end
end
