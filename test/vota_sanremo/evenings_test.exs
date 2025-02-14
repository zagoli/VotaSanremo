defmodule VotaSanremo.EveningsTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Evenings

  describe "evenings" do
    alias VotaSanremo.Evenings.Evening

    import VotaSanremo.{EveningsFixtures, EditionsFixtures, PerformancesFixtures}

    @invalid_attrs %{date: nil, description: nil, number: nil, votes_start: nil, votes_end: nil}

    test "list_evenings/0 returns all evenings" do
      evening = evening_fixture()
      assert Evenings.list_evenings() == [evening]
    end

    test "get_evening!/1 returns the evening with given id" do
      evening = evening_fixture()
      assert Evenings.get_evening!(evening.id) == evening
    end

    test "create_evening/1 with valid data creates a evening" do
      %{id: edition_id} = edition_fixture()

      valid_attrs = %{
        date: ~D[2024-04-29],
        description: "some description",
        number: 42,
        votes_start: ~U[2024-04-29 14:47:00Z],
        votes_end: ~U[2024-04-29 14:47:00Z],
        edition_id: edition_id
      }

      assert {:ok, %Evening{} = evening} = Evenings.create_evening(valid_attrs)
      assert evening.date == ~D[2024-04-29]
      assert evening.description == "some description"
      assert evening.number == 42
      assert evening.votes_start == ~U[2024-04-29 14:47:00Z]
      assert evening.votes_end == ~U[2024-04-29 14:47:00Z]
      assert evening.edition_id == edition_id
    end

    test "create_evening/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Evenings.create_evening(@invalid_attrs)
    end

    test "update_evening/2 with valid data updates the evening" do
      evening = evening_fixture()

      update_attrs = %{
        date: ~D[2024-04-30],
        description: "some updated description",
        number: 43,
        votes_start: ~U[2024-04-30 14:47:00Z],
        votes_end: ~U[2024-04-30 14:47:00Z]
      }

      assert {:ok, %Evening{} = evening} = Evenings.update_evening(evening, update_attrs)
      assert evening.date == ~D[2024-04-30]
      assert evening.description == "some updated description"
      assert evening.number == 43
      assert evening.votes_start == ~U[2024-04-30 14:47:00Z]
      assert evening.votes_end == ~U[2024-04-30 14:47:00Z]
    end

    test "update_evening/2 with invalid data returns error changeset" do
      evening = evening_fixture()
      assert {:error, %Ecto.Changeset{}} = Evenings.update_evening(evening, @invalid_attrs)
      assert evening == Evenings.get_evening!(evening.id)
    end

    test "delete_evening/1 deletes the evening" do
      evening = evening_fixture()
      assert {:ok, %Evening{}} = Evenings.delete_evening(evening)
      assert_raise Ecto.NoResultsError, fn -> Evenings.get_evening!(evening.id) end
    end

    test "delete_evening/1 deletes the evening and its performances" do
      evening = evening_fixture()
      performance_fixture(%{evening_id: evening.id})
      assert {:ok, %Evening{}} = Evenings.delete_evening(evening)
      assert_raise Ecto.NoResultsError, fn -> Evenings.get_evening!(evening.id) end
    end

    test "change_evening/1 returns a evening changeset" do
      evening = evening_fixture()
      assert %Ecto.Changeset{} = Evenings.change_evening(evening)
    end

    test "get_latest_evening_date/0 returns the latest evening date" do
      evening = evening_fixture(%{date: ~D[2024-01-01]})
      evening_fixture(%{date: ~D[2023-01-01]})
      evening_fixture(%{date: ~D[2022-01-01]})

      assert Evenings.get_latest_evening_date() == evening.date
    end

    test "get_evening_with_performances!/1 returns the evening with performances and associations" do
      evening = evening_fixture()
      performance = performance_fixture(%{evening_id: evening.id})

      loaded_evening = Evenings.get_evening_with_performances!(evening.id)
      assert loaded_evening.id == evening.id
      assert [loaded_performance] = loaded_evening.performances
      assert loaded_performance.id == performance.id
      # Verify the actual performer and performance_type data
      assert loaded_performance.performer.id == performance.performer_id
      assert loaded_performance.performance_type.id == performance.performance_type_id
    end

    test "get_voting_status/2 returns the correct status" do
      evening =
        evening_fixture(%{
          votes_start: ~U[2024-02-06 20:00:00Z],
          votes_end: ~U[2024-02-07 00:00:30Z]
        })

      # Before
      assert Evenings.get_voting_status(evening, ~U[2024-02-05 20:00:00Z]) == :before
      assert Evenings.get_voting_status(evening, ~U[2024-02-06 19:00:00Z]) == :before

      # During
      assert Evenings.get_voting_status(evening, ~U[2024-02-06 22:00:00Z]) == :open

      # After
      assert Evenings.get_voting_status(evening, ~U[2024-02-07 22:00:00Z]) == :after
      assert Evenings.get_voting_status(evening, ~U[2024-02-07 00:00:31Z]) == :after
    end
  end
end
