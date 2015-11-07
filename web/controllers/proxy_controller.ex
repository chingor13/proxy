defmodule Proxy.ProxyController do
  use Proxy.Web, :controller

  def get(conn, %{"path" => path}) do
    response = fetch(master_server, path)

    # fire of a process to compare the results asynchronously
    Task.async(fn -> fetch(secondary_server, path) |> Proxy.Comparer.compare(response) end)

    # force json response
    conn
      # |> apply_headers(response)
      |> put_resp_header("content-type", "application/json")
      |> send_resp(conn.status || 200, response.body)
  end

  defp post(conn, %{"path" => path}) do
    # FIXME: just proxy to the server and return the results
  end

  defp apply_headers(conn, response) do
    response.headers
      |> Enum.reduce(conn, fn({k, v}, conn) -> conn |> put_resp_header(String.downcase(k), v) end)
      # |> Enum.each(fn ({k, v}) -> conn = conn |> put_resp_header(String.downcase(k), v) end)
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

end
