defmodule Proxy do
  use Application
  import Supervisor.Spec, warn: false

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Start the endpoint when the application starts
  defp children do
    [
      supervisor(Proxy.Endpoint, [System.get_env("MASTER_BASE_URL"), System.get_env("SECONDARY_BASE_URL")])
    ]
  end

end
