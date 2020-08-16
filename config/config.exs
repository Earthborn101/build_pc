# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :build_pc,
  ecto_repos: [BuildPc.Repo]

# Configures the endpoint
config :build_pc, BuildPcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WZAiT4amYcdgyu3QQnWarxkkndsElDz0Mf/s2ll87ckeuXuOl/Yh7OMwT+ctSvSb",
  render_errors: [view: BuildPcWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BuildPc.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "NmFxJcut"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
