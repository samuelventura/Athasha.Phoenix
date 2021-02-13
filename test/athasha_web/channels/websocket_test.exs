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
      send(:test_run, {:on_connect, params})
      {:ok, socket}
    end

    def on_init(socket) do
      send(:test_run, {:on_init, self()})
      {:ok, socket}
    end

    def on_input(["echo", msg], %WebSocket{} = socket) do
      {:reply, :ok, msg, socket}
    end

    def on_input(msg, %WebSocket{} = socket) do
      send(:test_run, {:on_input, msg})
      {:ok, socket}
    end

    def on_control(msg, %WebSocket{} = socket) do
      send(:test_run, {:on_control, msg})
      {:ok, socket}
    end

    def on_info(msg, %WebSocket{} = socket) do
      {:push, msg, socket}
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
    Process.register(self(), :test_run)
    {:ok, pid} = WebsocketClient.start_link(self(), "#{@path}?key1=value1")
    assert_receive({:on_connect, %{"key1" => "value1"}}, 100)
    assert_receive({:on_init, wss_pid}, 100)

    WebsocketClient.send_message(pid, %{"key2" => 2})
    assert_receive({:on_input, %{"key2" => 2}}, 100)

    WebsocketClient.send_message(pid, [:echo, "msg1"])
    assert_receive({:text_msg, "msg1"}, 100)

    WebsocketClient.send_control(pid, :ping, "msg1")
    assert_receive({:on_control, {:ping, "msg1"}}, 100)
    assert_receive({:control, :pong, "msg1"}, 100)

    send(wss_pid, %{"key3" => 3})
    assert_receive({:text_msg, %{"key3" => 3}}, 100)
  end
end
