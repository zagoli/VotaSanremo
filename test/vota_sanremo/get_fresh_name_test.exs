defmodule VotaSanremo.GetFreshNameTest do
  use ExUnit.Case
  import VotaSanremo.GetFreshName

  describe "get_fresh_name/2" do
    test "returns the base name if it's not in the list" do
      assert get_fresh_name("New Series", ["Something else"]) == "New Series"
    end

    test "returns a unique name by appending a number to the base name" do
      assert get_fresh_name("Edition", ["Edition"]) == "Edition 2"
      assert get_fresh_name("Edition", ["Edition", "Edition 2"]) == "Edition 3"
    end
  end
end
