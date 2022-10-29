defmodule PathDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # PathDemo.Repo, # Not used in the demo context
      # Start the Telemetry supervisor
      PathDemoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PathDemo.PubSub},
      # Start the Endpoint (http/https)
      PathDemoWeb.Endpoint,
      PathDemo.Workers.Pathfinder
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PathDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PathDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
