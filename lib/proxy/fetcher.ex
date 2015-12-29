defmodule Proxy.Fetcher do
  require Logger

  @headers_to_allow [
    "content-type",
    "x-request-id",
    "x-frame-options",
    "x-runtime"
  ]

  def fetch_and_compare(path, opts) do
    {time, response} = fetch_with_timing(opts[:primary], path)

    if should_compare?(response) do
      Task.async(fn -> fetch_with_timing(opts[:secondary], path) |> Proxy.Comparison.compare({time, response}, path) end)
    else
      Logger.debug "skipping comparison of #{path}"
    end

    response
  end

  def fetch_with_timing(server, path) do
    :timer.tc(&fetch/2, [server, path])
  end

  def fetch(server, path) do
    [ server | path ]
      |> Enum.join("/")
      |> HTTPoison.get!
  end

  defp should_compare?(response) do
    response.status_code == 200 &&
      response.headers["Content-Type"] =~ "application/json"
  end

  defp headers_to_merge(response) do
    response.headers
      |> Enum.reduce(%{}, fn({k,v}, map) -> Map.put(map, String.downcase(k), v) end)
      |> Map.take(@headers_to_allow)
  end

end