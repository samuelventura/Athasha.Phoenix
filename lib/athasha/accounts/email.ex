defmodule Athasha.Accounts.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field :email, :string
    field :title, :string
    field :body, :string
    field :sent, :boolean

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:email, :title, :body, :sent])
    |> validate_required([:email, :title, :body])
  end
end
