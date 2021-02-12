defmodule AthashaWeb.WebSocket do
  require Logger
  require Phoenix.Endpoint
  alias AthashaWeb.WebSocket

  defstruct assigns: %{},
            endpoint: nil,
            handler: nil,
            transport: nil,
            private: %{}

  @type t :: %WebSocket{
          assigns: map,
          endpoint: atom,
          handler: atom,
          transport: atom,
          private: map
        }

  @callback on_spec(keyword) :: :supervisor.child_spec()
  @callback on_connect(params :: map, WebSocket.t()) ::
              {:ok, WebSocket.t()} | {:error, term} | :error
  @callback on_connect(params :: map, WebSocket.t(), connect_info :: map) ::
              {:ok, WebSocket.t()} | {:error, term} | :error
  @callback on_init(WebSocket.t()) :: {:ok, WebSocket.t()}
  @callback on_input(message :: term, WebSocket.t()) ::
              {:ok, WebSocket.t()}
              | {:reply, :ok | :error, message :: term, WebSocket.t()}
              | {:stop, reason :: term, WebSocket.t()}
  @callback on_control(message :: term, WebSocket.t()) ::
              {:ok, WebSocket.t()}
              | {:reply, :ok | :error, message :: term, WebSocket.t()}
              | {:stop, reason :: term, WebSocket.t()}
  @callback on_info(message :: term, WebSocket.t()) ::
              {:ok, WebSocket.t()}
              | {:push, message :: term, WebSocket.t()}
              | {:stop, reason :: term, WebSocket.t()}
  @callback on_exit(reason :: term, WebSocket.t()) :: :ok

  @optional_callbacks on_spec: 1,
                      on_connect: 2,
                      on_connect: 3,
                      on_init: 1,
                      on_control: 2,
                      on_exit: 2

  defmacro __using__(_opts) do
    quote do
      alias AthashaWeb.WebSocket
      import AthashaWeb.WebSocket
      @behaviour AthashaWeb.WebSocket
      @behaviour Phoenix.Socket.Transport

      def child_spec(opts), do: AthashaWeb.WebSocket.__child_spec__(__MODULE__, opts)

      def connect(map), do: AthashaWeb.WebSocket.__connect__(__MODULE__, map)

      def init(state), do: AthashaWeb.WebSocket.__init__(state)

      def handle_in(message, state), do: AthashaWeb.WebSocket.__in__(message, state)

      def handle_info(message, state), do: AthashaWeb.WebSocket.__info__(message, state)

      def handle_control(message, state), do: AthashaWeb.WebSocket.__control__(message, state)

      def terminate(reason, state), do: AthashaWeb.WebSocket.__exit__(reason, state)
    end
  end

  # opts => [endpoint: AthashaWeb.Endpoint, websocket: true, longpoll: false]
  def __child_spec__(handler, opts) do
    case function_exported?(handler, :on_spec, 1) do
      true -> handler.on_spec(opts)
      false -> %{id: Task, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
    end
  end

  # %{endpoint: endpoint, transport: :websocket, options: opts, params: params, connect_info: connect_info}
  def __connect__(handler, map) do
    %{
      endpoint: endpoint,
      transport: transport,
      params: params,
      connect_info: connect_info
    } = map

    socket = %WebSocket{
      assigns: %{},
      private: %{},
      handler: handler,
      endpoint: endpoint,
      transport: transport
    }

    case function_exported?(handler, :on_connect, 3) do
      true ->
        handler.on_connect(params, socket, connect_info)

      false ->
        case function_exported?(handler, :on_connect, 2) do
          true ->
            handler.on_connect(params, socket)

          false ->
            {:ok, socket}
        end
    end
  end

  def __init__(%{handler: handler} = socket) do
    case function_exported?(handler, :on_init, 1) do
      true ->
        handler.on_init(socket)

      false ->
        {:ok, socket}
    end
  end

  def __in__({payload, _opts}, %{handler: handler} = socket) do
    msg = Phoenix.json_library().decode!(payload)

    case handler.on_input(msg, socket) do
      {:reply, status, msg, socket} ->
        payload = Phoenix.json_library().encode_to_iodata!(msg)
        {:reply, status, {:text, payload}, socket}

      other ->
        other
    end
  end

  def __info__(message, %{handler: handler} = socket) do
    case handler.on_info(message, socket) do
      {:push, msg, socket} ->
        payload = Phoenix.json_library().encode_to_iodata!(msg)
        {:push, {:text, payload}, socket}

      other ->
        other
    end
  end

  def __control__({payload, _opts}, %{handler: handler} = socket) do
    case function_exported?(handler, :on_control, 2) do
      true ->
        case handler.on_control(payload, socket) do
          {:replay, status, msg, socket} ->
            payload = Phoenix.json_library().encode_to_iodata!(msg)
            {:replay, status, {:text, payload}, socket}

          other ->
            other
        end

      false ->
        {:ok, socket}
    end
  end

  def __exit__(reason, %{handler: handler} = socket) do
    case function_exported?(handler, :on_exit, 2) do
      true ->
        handler.on_exit(reason, socket)

      false ->
        {:ok, socket}
    end
  end

  def assign(%WebSocket{} = socket, key, value) do
    assign(socket, [{key, value}])
  end

  def assign(%WebSocket{} = socket, attrs)
      when is_map(attrs) or is_list(attrs) do
    %{socket | assigns: Map.merge(socket.assigns, Map.new(attrs))}
  end

  def verify(context, salt, token, opts \\ []) when is_binary(salt) do
    context
    |> get_key_base()
    |> Plug.Crypto.verify(salt, token, opts)
  end

  def decrypt(context, secret, token, opts \\ []) when is_binary(secret) do
    context
    |> get_key_base()
    |> Plug.Crypto.decrypt(secret, token, opts)
  end

  defp get_key_base(%WebSocket{} = socket),
    do: get_endpoint_key_base(socket.endpoint)

  defp get_endpoint_key_base(endpoint) do
    endpoint.config(:secret_key_base) ||
      raise """
      no :secret_key_base configuration found in #{inspect(endpoint)}.
      Ensure your environment has the necessary mix configuration. For example:
          config :my_app, MyAppWeb.Endpoint,
              secret_key_base: ...
      """
  end
end
