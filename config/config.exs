# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :path_demo,
  ecto_repos: []

# config :path_demo,
#   ecto_repos: [PathDemo.Repo]

# Configures the endpoint
config :path_demo, PathDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VHzSnWM+cn1cvL4ivVfIBm8guVaWOSD3uP7SGaTT2R5nivDJChVhN/R251KiSHUi",
  render_errors: [view: PathDemoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PathDemo.PubSub,
  live_view: [signing_salt: "2sC0cyKx"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :path_demo, PathDemo.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false


# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
