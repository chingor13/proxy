defmodule Proxy.Fetcher do
  require Logger

  def fetch_and_compare(conn, opts) do
    path = fullpath(conn)
    {time, response} = fetch_with_timing(path, opts[:primary])

    if should_compare?(response) do
      Task.async(fn -> fetch_with_timing(path, opts[:secondary]) |> Proxy.Comparison.compare({time, response}, path) end)
    else
      Logger.debug "skipping comparison of #{path}"
    end

    response
  end

  def fetch_with_timing(path, server) do
    :timer.tc(&fetch/2, [path, server])
  end

  def fetch(path, server) do
    [ server, path ]
      |> Enum.join("/")
      |> HTTPoison.get!
  end

  defp fullpath(conn) do
    conn.path_info
      |> Enum.join("/")
      |> append_query_string(conn.query_string)
  end

  defp append_query_string(str, ""), do: str
  defp append_query_string(str, query), do: "#{str}?#{query}"

  defp should_compare?(response) do
    response.status_code == 200 &&
      response.headers["Content-Type"] =~ "application/json"
  end

end