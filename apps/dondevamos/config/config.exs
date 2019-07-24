# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dondevamos,
  ecto_repos: [Dondevamos.Repo]

# Configures the endpoint
config :dondevamos, DondevamosWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/LUOcZDYTRCQbiuBM+lV21PLpM09FcyP01zmpJWIa9QSwAVEN9LJByEo1fbfBEs3",
  render_errors: [view: DondevamosWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dondevamos.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
