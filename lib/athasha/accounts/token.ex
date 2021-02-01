defmodule Athasha.Accounts.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    belongs_to :user, Athasha.Accounts.User
    field :token, :string
    field :origin, :string
    field :payload, :string
    field :done, :boolean

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:user_id, :token, :origin, :payload, :done])
    |> validate_required([:user_id, :token, :origin])
  end
end
