defmodule VotaSanremo.EditionsTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Editions
  alias VotaSanremo.Editions.Edition

  describe "editions" do
    import VotaSanremo.{EditionsFixtures, EveningsFixtures}

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
      valid_attrs = %{name: "someName", start_date: ~D[2024-04-29], end_date: ~D[2024-04-29]}

      assert {:ok, %Edition{} = edition} = Editions.create_edition(valid_attrs)
      assert edition.name == "someName"
      assert edition.start_date == ~D[2024-04-29]
      assert edition.end_date == ~D[2024-04-29]
    end

    test "create_edition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Editions.create_edition(@invalid_attrs)
    end

    test "update_edition/2 with valid data updates the edition" do
      edition = edition_fixture()

      update_attrs = %{
        name: "someUpdatedName",
        start_date: ~D[2024-04-30],
        end_date: ~D[2024-04-30]
      }

      assert {:ok, %Edition{} = edition} = Editions.update_edition(edition, update_attrs)
      assert edition.name == "someUpdatedName"
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

    test "delete_edition/1 deletes the editions and all its evenings" do
      edition = edition_fixture()
      evening_fixture(%{edition_id: edition.id})
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

    test "list_editions_with_evenings/0 returns all editions with associated evenings" do
      evening = evening_fixture()
      [edition] = Editions.list_editions_with_evenings()
      assert evening == List.first(edition.evenings)
    end

    test "get_latest_edition!/0 returs the latest edition when there is at least one edition" do
      _edition1 = edition_fixture(%{name: "Edition 1", start_date: ~D[2022-02-10]})
      edition2 = edition_fixture(%{name: "Edition 2", start_date: ~D[2023-02-10]})

      assert Editions.get_latest_edition!() == edition2
    end

    test "get_latest_edition!/0 throws error when there are no editions" do
      assert_raise Ecto.NoResultsError, &Editions.get_latest_edition!/0
    end

    test "get_latest_edition_with_evenings!/0 returs the latest edition when there is at least one edition, with associated evenings" do
      _edition1 = edition_fixture(%{name: "Edition 1", start_date: ~D[2022-02-10]})
      edition2 = edition_fixture(%{name: "Edition 2", start_date: ~D[2023-02-10]})
      evening = evening_fixture(%{edition_id: edition2.id})

      latest_edition = Editions.get_latest_edition_with_evenings!()
      assert latest_edition.id == edition2.id
      assert Ecto.assoc_loaded?(latest_edition.evenings)
      assert latest_edition.evenings == [evening]
    end

    test "get_latest_edition_with_evenings!/0 throws error when there are no editions" do
      assert_raise Ecto.NoResultsError, &Editions.get_latest_edition_with_evenings!/0
    end

    test "list_editions_names/0 returns a list of editions names" do
      edition_fixture(%{name: "Edition 1"})
      edition_fixture(%{name: "Edition 2"})

      editions = Editions.list_editions_names()

      assert Enum.member?(editions, "Edition 1")
      assert Enum.member?(editions, "Edition 2")
    end
  end
end
