defmodule Athasha.Edge.Port do
  use Ecto.Schema
  import Ecto.Changeset

  @name_length 32

  schema "ports" do
    field :node_id, :integer
    field :version, :integer
    field :name, :string
    field :script, :string
    field :config, :string
    field :disabled, :boolean
    timestamps()
  end

  def changeset(port, params) do
    port
    |> cast(params, [:user_id, :version, :name, :script, :config, :disabled])
    |> validate_required([:user_id, :version, :name, :script, :config, :disabled])
    |> validate_length(:name, max: @name_length)
  end
end
