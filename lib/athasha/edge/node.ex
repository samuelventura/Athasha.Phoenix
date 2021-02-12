defmodule Athasha.Edge.Node do
  use Ecto.Schema
  import Ecto.Changeset

  @name_length 32

  schema "nodes" do
    field :user_id, :integer
    field :version, :integer
    field :name, :string
    field :disabled, :boolean
    timestamps()
  end

  def changeset(node, params) do
    node
    |> cast(params, [:user_id, :version, :name, :disabled])
    |> validate_required([:user_id, :version, :name, :disabled])
    |> validate_length(:name, max: @name_length)
  end
end
