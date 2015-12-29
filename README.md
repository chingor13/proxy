# Proxy

Proxy requests to a primary and secondary (in the background) servers. Optionally compare response times and data between the two responses.

## Usage

If using this repo directly, you can call:

```elixir
Proxy.Endpoint.start_link(primary: primary_base_url, secondary: secondary_base_url)
```

If starting an OTP application, you can supervise:

```elixir
supervisor(Proxy.Endpoint, [[primary: primary_base_url, secondary: secondary_base_url, port: 8888]])
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add proxy to your list of dependencies in `mix.exs`:

        def deps do
          [{:proxy, "~> 0.0.1"}]
        end

  2. Ensure proxy is started before your application:

        def application do
          [applications: [:proxy]]
        end
