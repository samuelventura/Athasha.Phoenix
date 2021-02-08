defmodule AthashaWeb.EdgeLive do
  use AthashaWeb, :live_view

  alias Athasha.Edge
  alias Athasha.Edge.Node
  
  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    nodes = Edge.nodes_by_user(user_id)
    {:ok, assign(socket, user_id: user_id, nodes: nodes)}
  end

  @impl true
  def handle_event("add_node", _params, socket) do
    user_id = socket.assigns.user_id
    node = %Node{}
    |> Map.put(:name, "Unnamed Node")
    |> Map.put(:disabled, false)
    |> Map.put(:user_id, user_id)
    |> Map.put(:uuid, Ecto.UUID.generate())
    |> Edge.create_node!()
    |> Map.put(:ports, [])
    nodes = socket.assigns.nodes
    {:noreply, assign(socket, nodes: [node | nodes])}
  end

end
