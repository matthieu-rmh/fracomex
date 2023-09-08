# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

{:ok, project_path} = File.cwd
slides_path = "#{project_path}/priv/static/images/slides"
{:ok, slides_files} = File.ls(slides_path)

config :fracomex,
  direction_mail_address: "devis.fracomex@gmail.com",
  mail_sender: {"FRACOMEX Mayotte","fracomex@mgbi.mg"},
  mail_ccs: ["matthieu@phidia.onmicrosoft.com"]

config :fracomex,
  ecto_repos: [Fracomex.Repo],
  slides_files: slides_files
  # slides_files: Application.app_dir(:fracomex, "priv/static/images/slides") |> Tuple.to_list() |> Enum.at(1)

# Configures the endpoint
config :fracomex, FracomexWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FracomexWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Fracomex.PubSub,
  live_view: [signing_salt: "vQgynYPm"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
# config :fracomex, Fracomex.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

config :fracomex, Fracomex.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "ssl0.ovh.net",
  username: "fracomex@mgbi.mg",
  password: "Mgbi@261!",
  port: 587,
  retries: 1

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
import_config "#{config_env()}.exs"
