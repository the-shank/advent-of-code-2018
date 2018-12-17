defmodule Day17 do
  def part1 lines do
    ranges = parse_input lines
    state = build_state ranges
    print_state state
  end

  defp build_state ranges do
    {row_range, col_range} = Enum.reduce(ranges,
      fn {row_range, col_range}, {row_range0, col_range0} ->
	%Range{first: min_row0, last: max_row0} = row_range0
	%Range{first: min_col0, last: max_col0} = col_range0
	%Range{first: min_row, last: max_row} = row_range
	%Range{first: min_col, last: max_col} = col_range
	{(min(min_row0, min_row))..(max(max_row0, max_row)),
	(min(min_col0, min_col))..(max(max_col0, max_col))}
      end)
    map1 = for row <- row_range,
      col <- col_range,
      into: %{} do
      {{row, col}, :sand}
    end
    map2 = for {rows, cols} <- ranges,
      row <- rows,
      col <- cols,
      into: %{}
      do {{row, col}, :clay}
    end
    map = Map.merge(map1, map2)
    %{bb: {row_range, col_range}, ranges: ranges, contents: map}
  end

  defp parse_input lines do
    Enum.map(lines, &parse_line/1)
  end

  defp parse_line line do
    re = ~r/^([xy])=(\d+), ([xy])=(\d+)[.][.](\d+)$/
    [v1, val, v2, min, max] = Regex.run re, line, capture: :all_but_first
    {val, min,  max} = {String.to_integer(val), String.to_integer(min), String.to_integer(max)}
    [{"x", x_range}, {"y", y_range}] = Enum.sort [{v1,val..val},{v2,min..max}]
    {y_range, x_range}
  end

  def print_state state do
    contents = state.contents
    IO.puts ""
    {row_range, col_range} = state.bb
    IO.puts Enum.map(col_range, fn col ->
      if col == 500, do: ?+, else: ?.
    end)
    Enum.each(row_range, fn row ->
      IO.puts Enum.map(col_range, fn col ->
	pos = {row, col}
	case contents[pos] do
	  :sand -> ?.
	  :clay -> ?\#
	end
      end)
    end)
  end

end
