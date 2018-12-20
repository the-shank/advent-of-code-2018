defmodule Day20 do
  def part1 regex do
    directions = parse_regex regex
    {graph, _} = build_graph directions, {0, 0}, MapSet.new()
    {MapSet.new([{0, 0}]), [{0, 0}]}
    |> Stream.iterate(fn {visited, paths} -> expand_paths(visited, paths, graph) end)
    |> Stream.map(fn {_visited, paths} -> paths end)
    |> Stream.with_index(1)
    |> Enum.find(fn
      {[], index} ->
	index
      {[_ | _], _index} ->
	nil
    end)
    |> (fn {[], path_length} -> path_length end).()
  end

  defp expand_paths visited, paths, graph do
    Enum.reduce(paths, {visited, []},
      fn path, {visited, paths} ->
	case next_path_positions(graph, visited, path) do
	  [] ->
	    {visited, paths}
	  next_path_positions ->
	    visited = MapSet.union(visited, MapSet.new(next_path_positions));
	    {visited, next_path_positions ++ paths}
	end
      end)
  end

  defp next_path_positions graph, visited, position do
    adjacent_positions(position)
    |> Enum.reject(&MapSet.member?(visited, &1))
    |> Enum.filter(fn adjacent -> MapSet.member?(graph, {position, adjacent}) end)
  end

  defp adjacent_positions({x, y}), do: [{y - 1, x}, {y, x - 1}, {y, x + 1}, {y + 1, x}]

  defp build_graph [[_ | _] = alt_dirs | directions], pos, acc do
    Enum.reduce(alt_dirs, {acc, pos}, fn alt_dir, {acc, _} ->
      {acc, new_pos} = build_graph alt_dir, pos, acc;
      build_graph directions, new_pos, acc
    end)
  end

  defp build_graph [direction | directions], {x, y} = pos, acc do
    to = case direction do
	   :north -> {x, y + 1}
	   :south -> {x, y - 1}
	   :west ->  {x - 1, y}
	   :east ->  {x + 1, y}
	 end
    connection = {pos, to}
    case MapSet.member?(acc, connection) do
      true ->
	build_graph(directions, to, acc)
      false ->
	acc = MapSet.put(acc, connection)
	acc = MapSet.put(acc, {to, pos})
	build_graph(directions, to, acc)
    end
  end

  defp build_graph([], pos, acc), do: {acc, pos}

  defp parse_regex <<"^", rest::binary>> do
    {?\$, <<>>, result} = parse_direction rest, []
    result
  end

  defp parse_direction <<char, rest::binary>>, acc do
    case char do
      ?N -> parse_direction rest, [:north | acc]
      ?W -> parse_direction rest, [:west | acc]
      ?E -> parse_direction rest, [:east | acc]
      ?S -> parse_direction rest, [:south | acc]
      ?\( ->
	{alt, rest} = parse_alt rest, []
	parse_direction rest, [alt | acc]
      other ->
	{other, rest, Enum.reverse(acc)}
    end
  end

  defp parse_alt rest, acc do
    {terminator, rest, alt_group} = parse_direction rest, []
    case terminator do
      ?| -> parse_alt rest, [Enum.reverse(alt_group) | acc]
      ?\) -> {Enum.reverse(acc, [alt_group]), rest}
    end
  end
end
