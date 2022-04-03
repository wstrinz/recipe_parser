defmodule RecipeParserTest do
  use ExUnit.Case
  doctest RecipeParser

  test "greets the world" do
    assert RecipeParser.hello() == :world
  end
end
