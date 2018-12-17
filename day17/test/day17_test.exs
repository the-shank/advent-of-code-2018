defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part one, example" do
    assert Day17.part1(example1()) == 0
  end

  test "part one, real data" do
    assert Day17.part1(input()) == 0
  end

  test "part two example" do
    #assert Day17.part2(example1()) == 0
  end

  test "part two real data" do
    #assert Day17.part2(input()) == 0
  end

  defp example1() do
    """

    """
    |> String.trim
    |> String.split("\n")
  end


  defp input do
    """

    """
    |> String.trim
    |> String.split("\n")
  end
end
