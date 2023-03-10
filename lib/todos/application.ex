defmodule Todos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Todos.Repo,
      {Plug.Cowboy, scheme: :http, plug: Todos.Router, options: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Todos.Supervisor]

    Logger.info("Starting todos application...")

    Supervisor.start_link(children, opts)
  end
end
