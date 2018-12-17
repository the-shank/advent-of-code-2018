defmodule Day17 do
  def part1 lines do
    parse_input lines
  end

  defp parse_input lines do
    Enum.map(lines, &parse_line/1)
  end

  defp parse_line line do
    re = ~r/^([xy])=(\d+), ([xy])=(\d+)[.][.](\d+)$/
    [v1, val, v2, min, max] = Regex.run re, line, capture: :all_but_first
    {val, min,  max} = {String.to_integer(val), String.to_integer(min), String.to_integer(max)}
    [{"x", x_range}, {"y", y_range}] = Enum.sort [{v1,val..val},{v2,min..max}]
    {x_range, y_range}
  end
end
