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
    |> Repo.insert()
  end

  def create_node(user_id, name \\ "Unnamed node") do
    params = %{name: name, version: 1, disabled: false}
    node = %Node{user_id: user_id}

    Node.changeset(node, params)
    |> Repo.insert()
  end

  def remove_node(node_id) do
    from(n in Node, where: n.id == ^node_id)
    |> Repo.delete_all()
  end

  def create_port(node_id, name \\ "Unnamed port") do
    params = %{name: name, version: 1, disabled: false, script: "{}", config: "{}"}
    port = %Port{node_id: node_id}

    Port.changeset(port, params)
    |> Repo.insert()
  end

  def remove_port(port_id) do
    from(p in Port, where: p.id == ^port_id)
    |> Repo.delete_all()
  end

  def list_nodes(user_id) do
    Node
    |> where([n], n.user_id == ^user_id)
    |> Repo.all()
  end

  def list_ports(user_id) do
    Port
    |> join(:left, [p], n in Node, on: p.node_id == n.id)
    |> where([p, n], n.user_id == ^user_id)
    |> Repo.all()
  end
end
