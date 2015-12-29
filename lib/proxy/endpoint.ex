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

  def start_link(master, secondary) do
    Plug.Adapters.Cowboy.http __MODULE__, [master: master, secondary: secondary], [port: 8888]
  end

  def call(conn, opts) do
    # proxy request to master server
    response = conn.path_info
      |> Proxy.Fetcher.fetch_and_compare(opts)

    # send original response
    conn
      |> Plug.Logger.call(:debug)
      |> merge_resp_headers(headers_to_merge(response))
      |> send_resp(response.status_code, response.body)
  end

  defp headers_to_merge(response) do
    response.headers
      |> Enum.reduce(%{}, fn({k,v}, map) -> Map.put(map, String.downcase(k), v) end)
      |> Map.take(@headers_to_allow)
  end
end