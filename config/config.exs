# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :move_your_cedric,
  ecto_repos: [MoveYourCedric.Repo]

# Configures the endpoint
config :move_your_cedric, MoveYourCedricWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VHzSnWM+cn1cvL4ivVfIBm8guVaWOSD3uP7SGaTT2R5nivDJChVhN/R251KiSHUi",
  render_errors: [view: MoveYourCedricWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MoveYourCedric.PubSub,
  live_view: [signing_salt: "2sC0cyKx"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :move_your_cedric, MoveYourCedric.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
