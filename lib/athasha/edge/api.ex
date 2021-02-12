defmodule Athasha.Edge.Api do
  def ping(pid) do
    GenServer.call(pid, :ping)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def create_node(pid, name \\ "Unnamed node") when is_binary(name) do
    GenServer.call(pid, {:create_node, name})
  end

  def remove_node(pid, node_id) when is_integer(node_id) do
    GenServer.call(pid, {:remove_node, node_id})
  end

  def create_port(pid, node_id, name \\ "Unnamed port")
      when is_binary(name) and is_integer(node_id) do
    GenServer.call(pid, {:create_port, node_id, name})
  end

  def remove_port(pid, port_id) when is_integer(port_id) do
    GenServer.call(pid, {:remove_port, port_id})
  end

  # FIXME
  # Api level validation to ensure tampering kills the ofending
  # connection without disrupting the general service
end
