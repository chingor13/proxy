defmodule Proxy.Comparison do
  require Logger

  defstruct control: 0, experimental: 0, body_matched: true, headers_matched: true, path: ""

  def compare({time1, %HTTPoison.Response{body: body1, headers: headers1}}, {time2, %HTTPoison.Response{body: body2, headers: headers2}}, path) do

    comparison = %Proxy.Comparison{
      control: time2,
      experimental: time1,
      body_matched: true,
      headers_matched: true,
      path: Enum.join(path, "/")
    }

    Logger.debug "comparing both json responses"
    {:ok, data1} = Poison.decode(body1)
    {:ok, data2} = Poison.decode(body2)

    unless check(data1, data2) do
      Logger.debug "Failed to match data"
      Logger.debug inspect(data1)
      Logger.debug inspect(data2)
      comparison = %{comparison | body_matched: false}
    end

    unless check(headers1, headers2) do
      Logger.debug "Failed to match headers"
      comparison = %{comparison | headers_matched: false}
    end

    Logger.debug fn ->
      if time2 > time1 do
        "experimental (#{time1}μs) was faster than the control (#{time2}μs)"
      else
        "control (#{time2}μs) was faster than the experimental (#{time1}μs)"
      end
    end
    Logger.info(comparison)
  end

  defp check(a, b) do
    try do
      ^a = b
      ^b = a
      true
    rescue
      MatchError -> false
    end
  end

end

defimpl String.Chars, for: Proxy.Comparison do
  def to_string(comparison) do
    [comparison.path, comparison.control, comparison.experimental, comparison.body_matched, comparison.headers_matched]
      |> Enum.join(",")
  end
end