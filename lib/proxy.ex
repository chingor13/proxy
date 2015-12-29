defmodule Proxy do
  use Application
  import Supervisor.Spec, warn: false

  @default_port 8888

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
    [supervisor(Proxy.Endpoint, [endpoint_options])]
  end

  defp endpoint_options do
    Keyword.new([
      {:primary, System.get_env("PRIMARY_BASE_URL")},
      {:secondary, System.get_env("SECONDARY_BASE_URL")},
      {:port, port}
    ])
  end

  defp port do
    case System.get_env("PORT") do
      nil -> @default_port
      p   -> String.to_integer(p)
    end

  end

end
