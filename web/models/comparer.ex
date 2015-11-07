defmodule Proxy.Comparer do

  def compare(expected, path) do
    response = ["http://gnomonstag.corp.avvo.com" | path]
      |> Enum.join("/")
      |> HTTPoison.get!

    IO.puts(expected.body)
    IO.puts(response.body)
  end

end