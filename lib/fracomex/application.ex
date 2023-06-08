defmodule Fracomex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Fracomex.Repo,
      # Start the Ebp repository
      Fracomex.EbpRepo,
      # Start Synchro
      #Fracomex.SyncWorker,
      # Start the Telemetry supervisor
      FracomexWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Fracomex.PubSub},
      # Start the Endpoint (http/https)
      FracomexWeb.Endpoint,
      # Start a worker by calling: Fracomex.Worker.start_link(arg)
      # {Fracomex.Worker, arg}
      # ItemFamily Sync Worker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fracomex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FracomexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
