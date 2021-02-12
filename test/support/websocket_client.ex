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
    IO.inspect({"close", pid})
    send(pid, :close)
  end

  def send_message(pid, msg) do
    send(pid, {:send, msg})
  end

  def send_control(pid, opcode, msg \\ :none) do
    IO.inspect({"send_control", pid, opcode, msg})
    send(pid, {:control, opcode, msg})
  end

  def websocket_handle(any, _conn_state, sender) do
    IO.inspect({"websocket_handle", self(), any, sender})
    {:ok, sender}
  end

  def websocket_info({:send, msg}, _conn_state, sender) do
    IO.inspect({"websocket_info", self(), msg, sender})
    send(sender, {:msg, msg})
    {:ok, sender}
  end

  def websocket_info({:control, opcode, msg}, _conn_state, sender) do
    IO.inspect({"websocket_info", self(), opcode, msg, sender})
    send(sender, {:ctrl, opcode, msg})
    {:ok, sender}
  end

  def websocket_info(any, _conn_state, sender) do
    IO.inspect({"websocket_info", self(), any, sender})
    {:ok, sender}
  end

  def websocket_terminate(reason, _conn_state, sender) do
    IO.inspect({"websocket_terminate", self(), reason, sender})
    :ok
  end
end
