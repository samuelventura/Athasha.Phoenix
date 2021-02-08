defmodule Athasha.Repo.Migrations.EdgeSchema do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :user_id, references(:users)
      add :version, :integer
      add :name, :string
      add :disabled, :boolean

      timestamps()
    end

    create table(:ports) do
      add :node_id, references(:nodes)
      add :version, :integer
      add :name, :string
      add :disabled, :boolean
      add :script, :text
      add :config, :text

      timestamps()
    end

  end
end
