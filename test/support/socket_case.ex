defmodule AthashaWeb.SocketCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with sockets
      import AthashaWeb.SocketCase

      # The default endpoint for testing
      @endpoint AthashaWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Athasha.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Athasha.Repo, {:shared, self()})
    end

    :ok
  end

  defmacro connect(handler, params, connect_info \\ quote(do: %{})) do
    if endpoint = Module.get_attribute(__CALLER__.module, :endpoint) do
      quote do
        unquote(__MODULE__).__connect__(
          unquote(endpoint),
          unquote(handler),
          unquote(params),
          unquote(connect_info)
        )
      end
    else
      raise "module attribute @endpoint not set for socket/2"
    end
  end

  @doc false
  def __connect__(endpoint, handler, params, connect_info) do
    map = %{
      endpoint: endpoint,
      transport: :socket_test,
      options: [serializer: [{NoopSerializer, "~> 1.0.0"}]],
      params: __stringify__(params),
      connect_info: connect_info
    }

    with {:ok, state} <- handler.connect(map),
         {:ok, state} = handler.init(state),
         do: {:ok, state}
  end

  @doc false
  def __stringify__(%{__struct__: _} = struct),
    do: struct

  def __stringify__(%{} = params),
    do: Enum.into(params, %{}, &stringify_kv/1)

  def __stringify__(other),
    do: other

  defp stringify_kv({k, v}),
    do: {to_string(k), __stringify__(v)}
end
