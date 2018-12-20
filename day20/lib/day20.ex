defmodule Day20 do
  def part1 regex do
    directions = parse_regex regex
  end

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
