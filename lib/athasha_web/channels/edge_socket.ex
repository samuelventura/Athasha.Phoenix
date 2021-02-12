defmodule AthashaWeb.EdgeSocket do
  use AthashaWeb.WebSocket

  alias Athasha.Edge.Man
  # alias Athasha.Edge.Api

  def on_spec(_opts) do
    %{id: Man, start: {Man, :start_link, []}, restart: :permanent}
  end

  def on_connect(params, %WebSocket{} = socket) do
    IO.inspect({"on_connect", self(), params, socket})
    {:ok, socket}
  end

  def on_input(msg, %WebSocket{} = socket) do
    IO.inspect({"on_input", self(), msg, socket})
    {:ok, socket}
  end

  def on_info(msg, %WebSocket{} = socket) do
    IO.inspect({"on_info", self(), msg, socket})
    {:ok, socket}
  end
end
