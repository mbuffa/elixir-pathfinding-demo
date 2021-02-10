defmodule MoveYourCedric.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MoveYourCedric.Repo,
      # Start the Telemetry supervisor
      MoveYourCedricWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MoveYourCedric.PubSub},
      # Start the Endpoint (http/https)
      MoveYourCedricWeb.Endpoint,
      MoveYourCedric.Workers.Pathfinder
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MoveYourCedric.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MoveYourCedricWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
