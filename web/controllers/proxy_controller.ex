defmodule Proxy.ProxyController do
  use Proxy.Web, :controller

  @headers_to_allow [
    "content-type",
    "x-request-id",
    "x-frame-options",
    "x-runtime"
  ]

  def get(conn, %{"path" => path}) do
    {time, response} = fetch_with_timing(master_server, path)

    # fire of a process to compare the results asynchronously
    Task.async(fn -> fetch_with_timing(secondary_server, path) |> Proxy.Comparison.compare({time, response}, path) end)

    # force json response
    conn
      |> merge_resp_headers(headers_to_merge(response))
      |> send_resp(response.status_code, response.body)
  end

  defp post(conn, %{"path" => path}) do
    # FIXME: just proxy to the server and return the results
  end

  defp fetch_with_timing(server, path) do
    :timer.tc(&fetch/2, [server, path])
  end
  defp fetch(server, path) do
    [ server | path ]
      |> Enum.join("/")
      |> HTTPoison.get!
  end

  defp master_server do
    # Application.get_env(:proxy, :master_server)
    System.get_env("MASTER_BASE_URL")
  end

  defp secondary_server do
    # Application.get_env(:proxy, :secondary_server)
    System.get_env("SECONDARY_BASE_URL")
  end

  defp headers_to_merge(response) do
    response.headers
      |> Enum.reduce(%{}, fn({k,v}, map) -> Map.put(map, String.downcase(k), v) end)
      |> Map.take(@headers_to_allow)
  end

end
