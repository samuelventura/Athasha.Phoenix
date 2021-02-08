defmodule Athasha.Edge.Port do
  use Ecto.Schema
  import Ecto.Changeset

  @name_length 32

  schema "ports" do
    belongs_to :node, Athasha.Edge.Node
    field :version, :integer
    field :name, :string
    field :script, :string
    field :config, :string
    field :disabled, :boolean
    timestamps()
  end

  def changeset(port, params) do
    port
    |> cast(params, [:version, :name, :script, :config, :disabled])
    |> validate_required([:version, :name, :script, :config, :disabled])
    |> validate_length(:name, max: @name_length)
  end
end
