defmodule Athasha.Edge.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    belongs_to :user, Athasha.Auth.User
    field :uuid, :string
    field :name, :string
    field :disabled, :boolean
    has_many :ports, Athasha.Edge.Port
    timestamps()
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:uuid, :name, :disabled])
    |> validate_required([:uuid, :name, :disabled])
  end
end
