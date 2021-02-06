defmodule Athasha.Auth.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    belongs_to :user, Athasha.Auth.User
    field :token, :string
    field :origin, :string
    field :payload, :string
    field :expired, :boolean

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:user_id, :token, :origin, :payload, :expired])
    |> validate_required([:user_id, :token, :origin])
    |> unique_constraint(:token)
  end
end
