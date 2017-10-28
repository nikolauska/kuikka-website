defmodule Kuikka.Application do
  @moduledoc """
  Application defines
  """
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @spec start(term, term) :: Supervisor.on_start
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Kuikka.Repo, []),
      # Start the endpoint when the application starts
      supervisor(KuikkaWeb.Endpoint, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kuikka.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
