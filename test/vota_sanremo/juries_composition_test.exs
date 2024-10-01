defmodule VotaSanremo.JuriesCompositionTest do
  use VotaSanremo.DataCase

  describe "list_founded_juries/1" do
    import VotaSanremo.{AccountsFixtures, JuriesFixtures}
    alias VotaSanremo.Juries

    test "it returns the juries founded by a user" do
      user = user_fixture()
      jury = jury_fixture(%{founder: user.id})
      [found_jury] = Juries.list_founded_juries(user)
      assert found_jury == jury
    end

    test "it returns an empty list if the user has not founded any jury" do
      user = user_fixture()
      assert Juries.list_founded_juries(user) == []
    end
  end
end
