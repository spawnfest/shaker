defmodule ShakerTest do
  use ExUnit.Case
  doctest Shaker

  test "greets the world" do
    assert Shaker.hello() == :world
  end
end
