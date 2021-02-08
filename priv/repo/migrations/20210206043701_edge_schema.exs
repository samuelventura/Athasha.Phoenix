defmodule Athasha.Repo.Migrations.EdgeSchema do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :user_id, references(:users)
      add :uuid, :string
      add :name, :string
      add :disabled, :boolean, default: false

      timestamps()
    end

    create unique_index(:nodes, [:uuid])

    create table(:ports) do
      add :node_id, references(:nodes)
      add :uuid, :string
      add :name, :string
      add :script, :text
      add :config, :text
      add :disabled, :boolean, default: false

      timestamps()
    end

    create unique_index(:ports, [:uuid])
  end
end
