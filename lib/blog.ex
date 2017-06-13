defmodule Blog do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Blog.Endpoint, []),
      supervisor(Blog.Cache.Supervisor, []),
    ]

    Blog.Cache.Monitor.start

    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Blog.Endpoint.config_change(changed, removed)
    :ok
  end
end
