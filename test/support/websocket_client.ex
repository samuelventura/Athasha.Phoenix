defmodule AthashaWeb.WebsocketClient do
  def start_link(sender, url, headers \\ []) do
    :crypto.start()
    :ssl.start()

    :websocket_client.start_link(
      String.to_charlist(url),
      __MODULE__,
      sender,
      extra_headers: headers
    )
  end

  def init(sender, _conn_state) do
    {:ok, sender}
  end

  def close(pid) do
    send(pid, :close)
  end

  def send_message(pid, msg) do
    send(pid, {:send, msg})
  end

  def send_control(pid, opcode, msg \\ :none) do
    send(pid, {:control, opcode, msg})
  end

  def websocket_info({:send, msg}, _conn_state, sender) do
    payload = Phoenix.json_library().encode!(msg)
    {:reply, {:text, payload}, sender}
  end

  def websocket_info({:control, opcode, msg}, _conn_state, sender) do
    case msg do
      :none -> {:reply, opcode, sender}
      _ -> {:reply, {opcode, msg}, sender}
    end
  end

  def websocket_handle({:text, payload}, _conn_state, sender) do
    msg = Phoenix.json_library().decode!(payload)
    send(sender, {:text_msg, msg})
    {:ok, sender}
  end

  def websocket_handle({:binary, payload}, _conn_state, sender) do
    msg = Phoenix.json_library().decode!(payload)
    send(sender, {:binary_msg, msg})
    {:ok, sender}
  end

  def websocket_handle({opcode, msg}, _conn_state, sender) do
    send(sender, {:control, opcode, msg})
    {:ok, sender}
  end

  def websocket_terminate(_reason, _conn_state, _sender) do
    :ok
  end
end
