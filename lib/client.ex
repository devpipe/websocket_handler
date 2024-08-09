defmodule Websocket.ClientJS do
  @client_js """
  (function () {
      const client = {
          ws: null,
          jsonCallbacks: [],
          fileCallbacks: [],
          messageCallbacks: [],
          errorCallbacks: [],
          connectCallbacks: [],
          disconnectCallbacks: [],

          connect(url) {
              this.ws = new WebSocket(url);

              this.ws.onopen = () => {
                  this.connectCallbacks.forEach(callback => callback());
              };

              this.ws.onmessage = (event) => {
                  this.handleMessage(event.data);
              };

              this.ws.onclose = () => {
                  this.disconnectCallbacks.forEach(callback => callback());
              };

              this.ws.onerror = (error) => {
                  this.errorCallbacks.forEach(callback => callback(error));
              };
          },

          handleMessage(data) {
              try {
                  const parsedData = JSON.parse(data);
                  this.jsonCallbacks.forEach(callback => callback(parsedData));
              } catch (e) {
                  if (typeof data === 'string') {
                      this.messageCallbacks.forEach(callback => callback(data));
                  } else {
                      this.fileCallbacks.forEach(callback => callback(data));
                  }
              }
          },

          onJson(callback) {
              this.jsonCallbacks.push(callback);
          },

          onFile(callback) {
              this.fileCallbacks.push(callback);
          },

          onMessage(callback) {
              this.messageCallbacks.push(callback);
          },

          onError(callback) {
              this.errorCallbacks.push(callback);
          },

          onConnect(callback) {
              this.connectCallbacks.push(callback);
          },

          onDisconnect(callback) {
              this.disconnectCallbacks.push(callback);
          },

          send(data) {
              if (this.ws && this.ws.readyState === WebSocket.OPEN) {
                  if (typeof data === 'string' || data instanceof Blob) {
                      this.ws.send(data);
                  } else if (typeof data === 'object') {
                      this.ws.send(JSON.stringify(data));
                  } else {
                      console.error('Unsupported data type');
                  }
              } else {
                  console.error('WebSocket is not open');
              }
          }
      };

      // Type conversion functions
      function json(data) {
          return JSON.stringify(data);
      }

      function file(data) {
          if (data instanceof Blob) {
              return data;
          } else {
              console.error('Invalid file data');
          }
      }

      // Automatically connect to the WebSocket server
      client.connect(`ws://${window.location.host}/ws`);

      // Expose the client globally for custom usage
      window.client = client;
      window.json = json;
      window.file = file;
  })();
  """

  def client_js, do: @client_js
end
