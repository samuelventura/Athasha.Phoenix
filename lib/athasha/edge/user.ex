defmodule Athasha.Edge.User do
  use GenServer

  alias Athasha.Edge.Dao

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id)
  end

  def ping(pid) do
    GenServer.call(pid, :ping)
  end

  def new_node(pid, name \\ "Unnamed node") do
    GenServer.call(pid, {:new_node, name})
  end

  @impl true
  def init(user_id) do
    nodes = Dao.list_nodes(user_id)
    {:ok, %{user_id: user_id, nodes: nodes}}
  end

  @impl true
  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  @impl true
  def handle_call({:new_node, user_id, name}, _from, state) do
    node = Dao.new_node(user_id, name)
    {:reply, node, state}
  end
end
