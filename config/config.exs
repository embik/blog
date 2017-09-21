# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :blog, BlogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8VbcTXt2Y4OStipecUyJqUyHQ9SnkWyvG8SQLtyg5F3aOmAgNIfE/UELutXNIKli",
  render_errors: [view: BlogWeb.ErrorView, accepts: ~w(html json)],
  supported_locales: ~w(en de),
  pubsub: [name: Blog.PubSub,
           adapter: Phoenix.PubSub.PG2],
  show_cookie_notice: false,
  blogger_name: "Max Mustermann",
  blog_tagline: "Just some blog on tech",
  imprint_text: "Imprint text to comply with local law"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
