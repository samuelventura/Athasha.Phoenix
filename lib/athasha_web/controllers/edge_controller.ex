defmodule AthashaWeb.EdgeController do
  use AthashaWeb, :controller

  alias Athasha.Edge.Man
  alias Athasha.Edge.Api

  def mutation_post(conn, %{"mutation" => mutation} = params) do
    user_id = get_session(conn, :user_id)
    pid = Man.get_pid(user_id)

    case mutation do
      "create_node" ->
        json(conn, Api.create_node(pid))

      "create_port" ->
        %{"node_id" => node_id} = params
        json(conn, Api.create_port(pid, node_id))

      _ ->
        json(conn, {:error, "Unsupport mutation '#{mutation}'", params: params})
    end
  end
end
