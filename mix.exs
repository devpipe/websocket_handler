defmodule Websocket.MixProject do
  use Mix.Project

  @version "0.0.1"
  @description "Macro-based approach to handling WebSocket connections in a Plug-based Elixir application. It also serves a JavaScript WebSocket client at a specific endpoint, making it easy to integrate WebSocket communication into web applications."
  @repo "https://github.com/devpipe/websocket_handler"

  def project do
    [
      app: :websocket_handler,
      version: @version,
      description: @description,
      package: package(),
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "Websocket.Handler",
        source_ref: "v#{@version}",
        source_url: @repo,
        extras: ["README.md"]
      ],

    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Wess Cope"],
      links: %{"Github" => @repo}
    }
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.16"},
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"}
    ]
  end
end
