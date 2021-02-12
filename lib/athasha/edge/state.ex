defmodule Athasha.Edge.State do
  use GenServer

  alias Athasha.Edge.Dao

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id)
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  @impl true
  def init(user_id) do
    nodes =
      Dao.list_nodes(user_id)
      |> Map.new(fn n -> {n.id, n} end)

    ports =
      Dao.list_ports(user_id)
      |> Map.new(fn p -> {p.id, p} end)

    {:ok, %{user_id: user_id, nodes: nodes, ports: ports}}
  end

  @impl true
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:create_node, name}, _from, state) do
    case Dao.create_node(state.user_id, name) do
      {:ok, node} ->
        nodes = Map.put(state.nodes, node.id, node)
        state = Map.put(state, :nodes, nodes)
        {:reply, {:ok, node}, state}

      error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:remove_node, node_id}, _from, state) do
    case Map.pop(state.nodes, node_id) do
      {nil, _} ->
        {:reply, {:error, "Node #{node_id} not found"}, state}

      {node, nodes} ->
        state = Map.put(state, :nodes, nodes)
        # FIXME log DAO error
        Dao.remove_node(node_id)
        {:reply, {:ok, node}, state}
    end
  end

  @impl true
  def handle_call({:create_port, node_id, name}, _from, state) do
    case Map.get(state.nodes, node_id) do
      nil ->
        {:reply, {:error, "Node #{node_id} not found"}, state}

      _ ->
        case Dao.create_port(node_id, name) do
          {:ok, port} ->
            ports = Map.put(state.ports, port.id, port)
            state = Map.put(state, :ports, ports)
            {:reply, {:ok, port}, state}

          error ->
            {:reply, error, state}
        end
    end
  end

  @impl true
  def handle_call({:remove_port, port_id}, _from, state) do
    case Map.pop(state.ports, port_id) do
      {nil, _} ->
        {:reply, {:error, "Port #{port_id} not found"}, state}

      {port, ports} ->
        state = Map.put(state, :ports, ports)
        # FIXME log DAO error
        Dao.remove_port(port_id)
        {:reply, {:ok, port}, state}
    end
  end
end
