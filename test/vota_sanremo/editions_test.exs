defmodule VotaSanremo.EditionsTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Editions

  describe "editions" do
    alias VotaSanremo.Editions.Edition

    import VotaSanremo.EditionsFixtures

    @invalid_attrs %{name: nil, start_date: nil, end_date: nil}

    test "list_editions/0 returns all editions" do
      edition = edition_fixture()
      assert Editions.list_editions() == [edition]
    end

    test "get_edition!/1 returns the edition with given id" do
      edition = edition_fixture()
      assert Editions.get_edition!(edition.id) == edition
    end

    test "create_edition/1 with valid data creates a edition" do
      valid_attrs = %{name: "some name", start_date: ~D[2024-04-29], end_date: ~D[2024-04-29]}

      assert {:ok, %Edition{} = edition} = Editions.create_edition(valid_attrs)
      assert edition.name == "some name"
      assert edition.start_date == ~D[2024-04-29]
      assert edition.end_date == ~D[2024-04-29]
    end

    test "create_edition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Editions.create_edition(@invalid_attrs)
    end

    test "update_edition/2 with valid data updates the edition" do
      edition = edition_fixture()
      update_attrs = %{name: "some updated name", start_date: ~D[2024-04-30], end_date: ~D[2024-04-30]}

      assert {:ok, %Edition{} = edition} = Editions.update_edition(edition, update_attrs)
      assert edition.name == "some updated name"
      assert edition.start_date == ~D[2024-04-30]
      assert edition.end_date == ~D[2024-04-30]
    end

    test "update_edition/2 with invalid data returns error changeset" do
      edition = edition_fixture()
      assert {:error, %Ecto.Changeset{}} = Editions.update_edition(edition, @invalid_attrs)
      assert edition == Editions.get_edition!(edition.id)
    end

    test "delete_edition/1 deletes the edition" do
      edition = edition_fixture()
      assert {:ok, %Edition{}} = Editions.delete_edition(edition)
      assert_raise Ecto.NoResultsError, fn -> Editions.get_edition!(edition.id) end
    end

    test "change_edition/1 returns a edition changeset" do
      edition = edition_fixture()
      assert %Ecto.Changeset{} = Editions.change_edition(edition)
    end

    test "validates name uniqueness" do
      %{name: name} = edition_fixture()
      {:error, changeset} = Editions.create_edition(%{name: name})
      assert "has already been taken" in errors_on(changeset).name
    end
  end
end
