defmodule Frontend do
  @moduledoc """
  Frontend application starting code
  """
  use Application
  alias Frontend.Endpoint

  @spec start(term, term) :: term
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Frontend.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: Frontend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @spec config_change(term, term, term) :: :ok
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
