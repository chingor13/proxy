defmodule Proxy.Comparer do

  def compare(%HTTPoison.Response{body: body1, headers: headers1}, %HTTPoison.Response{body: body2, headers: headers2}) do
    IO.puts "comparing both json responses"
    IO.puts "1"
    IO.puts(body1)
    IO.puts "2"
    IO.puts(body2)
  end

end