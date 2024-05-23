defmodule VotaSanremo.PerformersTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Performers

  describe "performers" do
    alias VotaSanremo.Performers.Performer

    import VotaSanremo.{
      PerformersFixtures,
      PerformancesFixtures,
      VotesFixtures,
      EditionsFixtures,
      EveningsFixtures,
      TestSetupFixtures
    }

    @invalid_attrs %{name: nil}

    test "list_performers/0 returns all performers" do
      performer = performer_fixture()
      assert Performers.list_performers() == [performer]
    end

    test "get_performer!/1 returns the performer with given id" do
      performer = performer_fixture()
      assert Performers.get_performer!(performer.id) == performer
    end

    test "create_performer/1 with valid data creates a performer" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Performer{} = performer} = Performers.create_performer(valid_attrs)
      assert performer.name == "some name"
    end

    test "create_performer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Performers.create_performer(@invalid_attrs)
    end

    test "update_performer/2 with valid data updates the performer" do
      performer = performer_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Performer{} = performer} =
               Performers.update_performer(performer, update_attrs)

      assert performer.name == "some updated name"
    end

    test "update_performer/2 with invalid data returns error changeset" do
      performer = performer_fixture()
      assert {:error, %Ecto.Changeset{}} = Performers.update_performer(performer, @invalid_attrs)
      assert performer == Performers.get_performer!(performer.id)
    end

    test "delete_performer/1 deletes the performer" do
      performer = performer_fixture()
      assert {:ok, %Performer{}} = Performers.delete_performer(performer)
      assert_raise Ecto.NoResultsError, fn -> Performers.get_performer!(performer.id) end
    end

    test "change_performer/1 returns a performer changeset" do
      performer = performer_fixture()
      assert %Ecto.Changeset{} = Performers.change_performer(performer)
    end

    test "list_performers_avg_score_by_edition/1 lists performers with correct avg score" do
      scores = 1..10

      {edition_id, performer_name, first_performance_type, second_performance_type} =
        TestSetupFixtures.setup_for_avg_score_tests(scores)

      [first_avg_score, second_avg_score] =
        Performers.list_performers_avg_score_by_edition(edition_id)

      assert first_avg_score.name == performer_name
      assert second_avg_score.name == performer_name
      assert first_avg_score.performance_type in [first_performance_type, second_performance_type]

      assert second_avg_score.performance_type in [
               first_performance_type,
               second_performance_type
             ]

      assert first_avg_score.score == Enum.sum(scores) / Enum.count(scores)
      assert second_avg_score.score == Enum.sum(scores) / Enum.count(scores)
    end

    test "list_performers_weighted_avg_score_by_edition/1 lists performers with correct avg score" do
      scores = 1..10

      {edition_id, performer_name, first_performance_type, second_performance_type} =
        TestSetupFixtures.setup_for_avg_score_tests(scores)

      [first_avg_score, second_avg_score] =
        Performers.list_performers_weighted_avg_score_by_edition(edition_id)

      assert first_avg_score.name == performer_name
      assert second_avg_score.name == performer_name
      assert first_avg_score.performance_type in [first_performance_type, second_performance_type]

      assert second_avg_score.performance_type in [
               first_performance_type,
               second_performance_type
             ]

      assert first_avg_score.score == Enum.sum(scores) / Enum.count(scores) * Enum.sum(scores)
      assert second_avg_score.score == Enum.sum(scores) / Enum.count(scores) * Enum.sum(scores)
    end
  end
end
