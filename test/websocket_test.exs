defmodule WebsocketTest do
  use ExUnit.Case
  doctest Websocket

  test "greets the world" do
    assert Websocket.hello() == :world
  end
end
