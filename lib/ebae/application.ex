defmodule Ebae.Application do
  import Supervisor.Spec

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Ebae.Repo,
      # Start the endpoint when the application starts
      EbaeWeb.Endpoint,
      # Starts a worker by calling: Ebae.Worker.start_link(arg)
      supervisor(Exq, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ebae.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EbaeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
