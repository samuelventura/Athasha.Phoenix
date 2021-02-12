defmodule AthashaWeb.EdgeSocketTest do
  use AthashaWeb.SocketCase
  alias AthashaWeb.EdgeSocket

  test "ping replies with status ok" do
    {:ok, _socket} = connect(EdgeSocket, %{user_id: 1})
    # assert result == {:ok, nil}
  end
end
