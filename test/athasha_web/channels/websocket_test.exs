defmodule AthashaWeb.WebSocketTest do
  use ExUnit.Case, async: true

  alias AthashaWeb.WebsocketClient
  alias __MODULE__.Endpoint
  alias __MODULE__.UserWebSocket

  @moduletag :capture_log
  @port 9988
  @path "ws://127.0.0.1:#{@port}/ws/websocket"

  Application.put_env(
    :phoenix_test,
    Endpoint,
    https: false,
    http: [port: @port],
    debug_errors: false,
    server: true
  )

  defmodule UserWebSocket do
    use AthashaWeb.WebSocket

    def on_connect(params, %WebSocket{} = socket) do
      IO.inspect({"on_connect", self(), params, socket})
      {:ok, socket}
    end

    def on_input(msg, %WebSocket{} = socket) do
      IO.inspect({"on_input", self(), msg, socket})
      {:reply, :ok, msg, socket}
    end

    def on_info(msg, %WebSocket{} = socket) do
      IO.inspect({"on_info", self(), msg, socket})
      {:ok, socket}
    end

    def on_control(msg, %WebSocket{} = socket) do
      IO.inspect({"on_control", self(), msg, socket})
      {:ok, socket}
    end

    def on_exit(reason, %WebSocket{} = socket) do
      IO.inspect({"on_exit", self(), reason, socket})
      :ok
    end
  end

  defmodule Endpoint do
    use Phoenix.Endpoint, otp_app: :phoenix_test

    socket "/ws", UserWebSocket, websocket: true
  end

  setup_all do
    Endpoint.start_link()
    :ok
  end

  test "web socket test" do
    {:ok, pid} = WebsocketClient.start_link(self(), "#{@path}?key2=value2")
    WebsocketClient.send_message(pid, "{}")
    assert_receive({:msg, "{}"}, 100)
    WebsocketClient.send_control(pid, "opt", "msg")
    assert_receive({:ctrl, "opt", "msg"}, 100)
  end
end
