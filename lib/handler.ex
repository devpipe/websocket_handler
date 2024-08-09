
defmodule Websocket.Handler do
  @moduledoc """
  Websocket.Handler provides a macro-based approach to handle WebSocket connections in a Plug-based application.
  This module also serves the JavaScript WebSocket client code at the `/ws/client.js` endpoint.

  ## Usage

  To use Websocket.Handler, you need to include it in your application’s router module and define event handlers using the provided macros.

  ```elixir
  defmodule MyWebsocketRouter do
    use Websocket.Handler

    on(:connect) do
      IO.puts("Client connected")
    end

    on(:disconnect) do
      IO.puts("Client disconnected")
    end

    on(:json) do
      IO.puts("Received JSON: \#{inspect(conn.json)}")
    end

    on(:file) do
      # Save the file to disk or process it
      IO.puts("Received file")
    end

    on(:message) do
      IO.puts("Received message: \#{conn.message}")
    end
  end
  ```

  ## Routes

  - **`get "/client.js"`**: Serves the JavaScript WebSocket client at the `/ws/client.js` endpoint.
  - **`forward "/ws"`**: Reserved for WebSocket connections. Forwards WebSocket requests to the module where event handlers are defined.

  ## Macros

  - **`on(event, do: block)`**: Defines a callback for a specific WebSocket event. Supported events include:
    - `:connect`: Triggered when a client connects.
    - `:disconnect`: Triggered when a client disconnects.
    - `:json`: Triggered when a JSON message is received.
    - `:file`: Triggered when binary data (file) is received.
    - `:message`: Triggered when a plain text message is received.

  """

  use Plug.Builder

  defmacro __using__(_) do
    quote do
      use Plug.Builder

      plug :match
      plug :dispatch

      get "/client.js" do
        conn
        |> put_resp_content_type("application/javascript")
        |> send_resp(200, Websocket.ClientJS.client_js())
      end

      forward "/ws", to: __MODULE__

      match _ do
        send_resp(conn, 404, "Not Found")
      end
    end
  end

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.method do
      "GET" -> upgrade_to_websocket(conn)
      _ -> conn |> Plug.Conn.send_resp(405, "Method Not Allowed")
    end
  end

  defp upgrade_to_websocket(conn) do
    case Plug.Conn.upgrade_adapter(conn, :websocket, {__MODULE__, %{}}) do
      {:ok, upgraded_conn} -> upgraded_conn
      {:error, _reason} ->
        conn
        |> Plug.Conn.send_resp(400, "Bad Request")
        |> Plug.Conn.halt()
    end
  end

  def websocket_init(_transport_name, req, opts) do
    handle_event(:connect, req)
    {:ok, req, opts}
  end

  def websocket_handle({:text, message}, req, opts) do
    conn = %{req: req, message: message}

    conn =
      case detect_message_type(message) do
        :json ->
          parsed_message = Jason.decode!(message)
          Map.put(conn, :json, parsed_message)

        _ ->
          conn
      end

    handle_event(conn_type(conn), conn)
    {:ok, req, opts}
  end

  def websocket_handle({:binary, data}, req, opts) do
    conn = %{req: req, file: data}
    handle_event(:file, conn)
    {:ok, req, opts}
  end

  def websocket_terminate(_reason, _req, _opts) do
    handle_event(:disconnect, %{})
    :ok
  end

  defp conn_type(%{json: _}), do: :json
  defp conn_type(_), do: :message

  defp detect_message_type(message) do
    case Jason.decode(message) do
      {:ok, _} -> :json
      {:error, _} -> :text
    end
  rescue
    _ -> :text
  end

  def handle_event(event, conn) do
    callbacks = Module.get_attribute(__MODULE__, :callbacks)
    if callback = callbacks[event] do
      callback.(conn)
    else
      conn
    end
  end
end
