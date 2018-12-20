defmodule Day20 do
  def part1 re do
    {:ok, re} = Regex.compile re
    Regex.match? re, "ENWWWNEEE"
  end
end
