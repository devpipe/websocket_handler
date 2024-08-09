
# Websocket Handler

Websocket Handler is a macro-based approach to handling WebSocket connections in a Plug-based Elixir application. It also serves a JavaScript WebSocket client at a specific endpoint, making it easy to integrate WebSocket communication into web applications.

## `Websocket.Handler`

Module allows you to define WebSocket routes and event handlers using a simple, macro-based syntax. It automatically serves the JavaScript WebSocket client at the `/ws/client.js` endpoint.

### Usage

To use `Websocket.Handler`, you need to include it in your application’s router module and define event handlers using the provided macros.

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
    IO.puts("Received JSON: #{inspect(conn.json)}")
  end

  on(:file) do
    # Save the file to disk or process it
    IO.puts("Received file")
  end

  on(:message) do
    # Message is just plain text.
    IO.puts("Received message: #{conn.message}")
  end
end
```

Then in your Plug router, simply forward your websocket route to your handler.

```elixir
defmodule MyAppRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/ws", to: MyWebsocketRouter

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
```

#### Events

  - `:connect`: Triggered when a client connects.
  - `:disconnect`: Triggered when a client disconnects.
  - `:json`: Triggered when a JSON message is received.
  - `:file`: Triggered when binary data (file) is received.
  - `:message`: Triggered when a plain text message is received.

> `ws/client.js` is generated to handle websocket connection and callbacks for on: json, text/message and file. Just include it.

## Example Usage

Here’s how you can include and use the WebSocket client in your HTML files:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebSocket Client</title>
</head>
<body>
    <script src="/ws/client.js"></script>
    <script>
        client.onJson((data) => {
            console.log('Received JSON:', data);
        });

        client.onFile((data) => {
            console.log('Received file data');
            const fileUrl = URL.createObjectURL(data);
            const link = document.createElement('a');
            link.href = fileUrl;
            link.download = 'downloaded_file';
            link.click();
            URL.revokeObjectURL(fileUrl);
        });

        client.onMessage((message) => {
            console.log('Received message:', message);
        });

        client.onConnect(() => {
            console.log('Connected to WebSocket server');
        });

        client.onDisconnect(() => {
            console.log('Disconnected from WebSocket server');
        });

        // Sending different types of data using the new syntax
        client.send(json({ hello: "world" }));
        client.send("some text");
        const fileBlob = new Blob(["This is a file content"], { type: 'text/plain' });
        client.send(file(fileBlob));
    </script>
</body>
</html>
```


## License

This project is licensed under the MIT License.
