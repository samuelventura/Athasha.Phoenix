defmodule Athasha.Edge.Node do
  use Ecto.Schema
  import Ecto.Changeset

  @name_length 32

  schema "nodes" do
    belongs_to :user, Athasha.Auth.User
    field :version, :integer
    field :name, :string
    field :disabled, :boolean
    has_many :ports, Athasha.Edge.Port
    timestamps()
  end

  def changeset(node, params) do
    node
    |> cast(params, [:version, :name, :disabled])
    |> validate_required([:version, :name, :disabled])
    |> validate_length(:name, max: @name_length)
  end
end
