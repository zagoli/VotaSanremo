defmodule VotaSanremo.JuriesCompositionTest do
  use VotaSanremo.DataCase
  import VotaSanremo.{AccountsFixtures, JuriesFixtures}
  alias VotaSanremo.Juries

  describe "list_founded_juries/1" do
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

  describe "list_member_juries/1" do
    test "it returns the juries the user is a member of" do
      user = user_fixture()
      jury = jury_fixture()
      Juries.add_member(jury, user)
      [jury_member] = Juries.list_member_juries(user)
      assert jury_member == jury
    end

    test "it returns an empty list if the user is not a member of any jury" do
      user = user_fixture()
      assert Juries.list_member_juries(user) == []
    end
  end
end
