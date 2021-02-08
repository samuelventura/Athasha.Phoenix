defmodule Athasha.Edge.Dao do
  import Ecto.Query, warn: false

  alias Athasha.Repo

  alias Athasha.Edge.Node
  alias Athasha.Edge.Port

  alias Athasha.Auth.User

  import Athasha.Auth.Tools

  def create_user(name, email, password) do
    params = %{
      name: name,
      email: email,
      origin: "127.0.0.1",
      confirmed: true,
      password: encrypt_ifn_blank(password)
    }

    %User{}
    |> User.changeset(params)
    |> Repo.insert!()
  end

  def new_node(user_id, name \\ "Unnamed node") do
    params = %{name: name, version: 1, disabled: false}
    node = %Node{user_id: user_id}

    n =
      Node.changeset(node, params)
      |> Repo.insert!()

    {n.id, n.version, n.name, n.disabled}
  end

  def new_port(node_id, name \\ "Unnamed port") do
    params = %{name: name, version: 1, disabled: false, script: "{}", config: "{}"}
    port = %Port{node_id: node_id}

    p =
      Port.changeset(port, params)
      |> Repo.insert!()

    {p.id, p.version, p.name, p.disabled, p.script, p.config}
  end

  def list_nodes(user_id) do
    query =
      from n in "nodes",
        join: p in "ports",
        on: n.id == p.node_id,
        where: n.user_id == ^user_id,
        select: {
          {n.id, n.version, n.name, n.disabled},
          {p.id, p.version, p.name, p.disabled, p.script, p.config}
        }

    Repo.all(query)
  end
end
