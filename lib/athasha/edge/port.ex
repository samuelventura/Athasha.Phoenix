defmodule Athasha.Edge.Port do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ports" do
    belongs_to :node, Athasha.Edge.Node
    field :uuid, :string
    field :name, :string
    field :script, :string
    field :config, :string
    field :disabled, :boolean
    timestamps()
  end

  @doc false
  def changeset(controller, attrs) do
    controller
    |> cast(attrs, [:uuid, :name, :script, :config, :disabled])
    |> validate_required([:uuid, :name, :script, :config, :disabled])
  end
end
