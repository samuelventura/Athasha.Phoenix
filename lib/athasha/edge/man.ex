defmodule Athasha.Edge.Man do
  use GenServer

  alias Athasha.Edge.User

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :edge_man)
  end

  def get_user(user_id) do
    GenServer.call(:edge_man, {:get_user, user_id})
  end

  @impl true
  def init(nil) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, map) do
    map = remove_by_pid(map, pid)
    {:noreply, map}
  end

  @impl true
  def handle_call({:get_user, user_id}, _from, map) do
    {map, pid} = get_pid(map, user_id)
    {:reply, pid, map}
  end

  defp get_pid(map, user_id) do
    case Map.get(map, user_id) do
      nil ->
        {:ok, pid} = User.start_link(user_id)

        map =
          map
          |> Map.put(user_id, pid)
          |> Map.put(pid, user_id)

        {map, pid}

      pid ->
        {map, pid}
    end
  end

  defp remove_by_pid(map, pid) do
    case Map.get(map, pid) do
      nil ->
        map

      user_id ->
        map
        |> Map.delete(pid)
        |> Map.delete(user_id)
    end
  end
end
