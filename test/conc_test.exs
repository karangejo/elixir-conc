defmodule ConcTest do
  use ExUnit.Case
  doctest Conc

  test "simple map" do
    assert Conc.map([1,2,3], fn x -> x+x end) == [2,4,6]
  end

end
