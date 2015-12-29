defmodule Proxy.Endpoint do
  @behaviour Plug
  import Plug.Conn

  @headers_to_allow [
    "content-type",
    "x-request-id",
    "x-frame-options",
    "x-runtime"
  ]

  def init(opts), do: opts

  def start_link(opts \\ []) do
    {endpoint_opts, cowboy_opts} = Keyword.split(opts, [:primary, :secondary])
    Plug.Adapters.Cowboy.http __MODULE__, endpoint_opts, cowboy_opts
  end

  def call(conn, opts) do
    conn = conn |> Plug.Logger.call(:debug)

    # proxy request to primary server
    response = conn
      |> Proxy.Fetcher.fetch_and_compare(opts)

    # send original response
    conn
      |> merge_resp_headers(headers_to_merge(response))
      |> send_resp(response.status_code, response.body)
  end

  defp headers_to_merge(response) do
    response.headers
      |> Enum.reduce(%{}, fn({k,v}, map) -> Map.put(map, String.downcase(k), v) end)
      |> Map.take(@headers_to_allow)
  end
end