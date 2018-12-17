defmodule Day17 do
  def part1 lines do
    ranges = parse_input lines
    state = build_state ranges
    min_row = Enum.min(state.row_range)
    spring = {min_row - 1, 500}
    {result, state} = fill_below(state, spring)
    IO.inspect result
    print_state state
    count_water_areas state
  end

  defp count_water_areas state do
    Enum.count(state.contents, fn {_, what} ->
      what == :flowing || what == :settled
    end)
  end

  defp fill_below state, {row, col} = pos do
    below = {row + 1, col}
    case at_below(state, below) do
      :outside ->
	{:done, state}
      :blocked ->
	{:blocked, state}
      :free ->
	state = fill state, below, :flowing
	case fill_below(state, below) do
	  {:blocked, state} ->
	    case fill_horizontal(state, below, -1, :flowing) do
	      {:done, state} ->
		fill_horizontal(state, below, 1, :flowing)
	      {:blocked, state} ->
		case fill_horizontal(state, below, 1, :flowing) do
		  {:blocked, state} ->
		    {:blocked, state} = fill_horizontal(state, below, -1, :settled)
		    {:blocked, state} = fill_horizontal(state, below, 1, :settled)
		    state = fill state, below, :settled;
		    {:blocked, state}
		  {:done, state} ->
		    {:done, state}
		end
	    end
	  {:done, state} ->
	    {:done, state}
	end
    end
  end

  defp fill_horizontal state, {row, col}, direction, elem do
    pos = {row, col + direction}
    case at_side(state, {row, col + direction}) do
      :outside ->
	{:done, state}
      :free ->
	state = fill state, pos, elem
	case at_below(state, {row + 1, col + direction}) do
	  :blocked ->
	    fill_horizontal state, pos, direction, elem
	  _ ->
	    fill_below state, {row - 1, col + direction}
	end
      :blocked ->
	{:blocked, state}
    end
  end

  defp fill state, pos, elem do
    contents = state.contents
    contents = Map.put(contents, pos, elem)
    Map.put(state, :contents, contents)
  end

  defp at_side state, pos do
    case at_raw(state, pos) do
      :clay -> :blocked
      :settled -> :free
      other -> other
    end
  end

  defp at_below state, pos do
    case at_raw(state, pos) do
      :clay -> :blocked
      :settled -> :blocked
      other -> other
    end
  end

  defp at_raw state, {row, _} = pos do
    case state.contents[pos] do
      :clay -> :clay
      :settled -> :settled
      :flowing -> :free
      nil ->
	case row in state.row_range do
	  true -> :free
	  false -> :outside
	end
    end
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
    map = for {rows, cols} <- ranges,
      row <- rows,
      col <- cols,
      into: %{}
      do {{row, col}, :clay}
    end
    %{bb: {row_range, col_range}, row_range: row_range, ranges: ranges, contents: map}
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
	  nil -> ?.
	  :clay -> ?\#
	  :flowing -> ?|
	  :settled -> ?\~
	end
      end)
    end)
    IO.inspect state.bb
  end

end
