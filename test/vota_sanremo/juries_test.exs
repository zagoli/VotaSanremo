defmodule VotaSanremo.JuriesTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Juries

  describe "juries" do
    alias VotaSanremo.Juries.Jury

    import VotaSanremo.JuriesFixtures

    @invalid_attrs %{name: nil, founder: -1}

    test "list_juries/0 returns all juries" do
      jury = jury_fixture()
      assert Juries.list_juries() == [jury]
    end

    test "get_jury!/1 returns the jury with given id" do
      jury = jury_fixture()
      assert Juries.get_jury!(jury.id) == jury
    end

    test "create_jury/1 with valid data creates a jury" do
      %{id: user_id} = VotaSanremo.AccountsFixtures.user_fixture()
      valid_attrs = %{name: "some name", founder: user_id}

      assert {:ok, %Jury{} = jury} = Juries.create_jury(valid_attrs)
      assert jury.name == "some name"
      assert jury.founder == user_id
    end

    test "create_jury/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Juries.create_jury(@invalid_attrs)
    end

    test "update_jury/2 with valid data updates the jury" do
      jury = jury_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Jury{} = jury} = Juries.update_jury(jury, update_attrs)
      assert jury.name == "some updated name"
    end

    test "update_jury/2 with invalid data returns error changeset" do
      jury = jury_fixture()
      assert {:error, %Ecto.Changeset{}} = Juries.update_jury(jury, @invalid_attrs)
      assert jury == Juries.get_jury!(jury.id)
    end

    test "delete_jury/1 deletes the jury" do
      jury = jury_fixture()
      assert {:ok, %Jury{}} = Juries.delete_jury(jury)
      assert_raise Ecto.NoResultsError, fn -> Juries.get_jury!(jury.id) end
    end

    test "change_jury/1 returns a jury changeset" do
      jury = jury_fixture()
      assert %Ecto.Changeset{} = Juries.change_jury(jury)
    end
  end
end
