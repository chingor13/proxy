defmodule Proxy.ProxyController do
  use Proxy.Web, :controller

  def proxy(conn, %{"path" => path}) do
    response = ["http://gnomonstag.corp.avvo.com" | path]
      |> Enum.join("/")
      |> HTTPoison.get!

    Task.async(fn -> Proxy.Comparer.compare(response, path) end)

    # force json response
    conn
      # |> apply_headers(response)
      |> put_resp_header("content-type", "application/json")
      |> send_resp(conn.status || 200, response.body)
  end

  defp apply_headers(conn, response) do
    response.headers
      |> Enum.reduce(conn, fn({k, v}, conn) -> conn |> put_resp_header(String.downcase(k), v) end)
      # |> Enum.each(fn ({k, v}) -> conn = conn |> put_resp_header(String.downcase(k), v) end)
  end

end
