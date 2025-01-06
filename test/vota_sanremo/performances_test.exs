defmodule VotaSanremo.PerformancesTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Performances

  describe "performance_types" do
    alias VotaSanremo.Performances.PerformanceType

    import VotaSanremo.PerformancesFixtures

    @invalid_attrs %{type: nil}

    test "list_performance_types/0 returns all performance_types" do
      performance_type = performance_type_fixture()
      assert Performances.list_performance_types() == [performance_type]
    end

    test "get_performance_type!/1 returns the performance_type with given id" do
      performance_type = performance_type_fixture()
      assert Performances.get_performance_type!(performance_type.id) == performance_type
    end

    test "create_performance_type/1 with valid data creates a performance_type" do
      valid_attrs = %{type: "some type"}

      assert {:ok, %PerformanceType{} = performance_type} =
               Performances.create_performance_type(valid_attrs)

      assert performance_type.type == "some type"
    end

    test "create_performance_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Performances.create_performance_type(@invalid_attrs)
    end

    test "update_performance_type/2 with valid data updates the performance_type" do
      performance_type = performance_type_fixture()
      update_attrs = %{type: "some updated type"}

      assert {:ok, %PerformanceType{} = performance_type} =
               Performances.update_performance_type(performance_type, update_attrs)

      assert performance_type.type == "some updated type"
    end

    test "update_performance_type/2 with invalid data returns error changeset" do
      performance_type = performance_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Performances.update_performance_type(performance_type, @invalid_attrs)

      assert performance_type == Performances.get_performance_type!(performance_type.id)
    end

    test "delete_performance_type/1 deletes the performance_type" do
      performance_type = performance_type_fixture()
      assert {:ok, %PerformanceType{}} = Performances.delete_performance_type(performance_type)

      assert_raise Ecto.NoResultsError, fn ->
        Performances.get_performance_type!(performance_type.id)
      end
    end

    test "change_performance_type/1 returns a performance_type changeset" do
      performance_type = performance_type_fixture()
      assert %Ecto.Changeset{} = Performances.change_performance_type(performance_type)
    end
  end

  describe "performances" do
    alias VotaSanremo.Performances.Performance
    alias VotaSanremo.Votes

    import VotaSanremo.{
      PerformancesFixtures,
      EveningsFixtures,
      PerformersFixtures,
      AccountsFixtures,
      VotesFixtures
    }

    @invalid_attrs %{performance_type_id: nil, performer_id: nil, evening_id: nil}

    test "list_performances/0 returns all performances" do
      performance = performance_fixture()
      assert Performances.list_performances() == [performance]
    end

    test "get_performance!/1 returns the performance with given id" do
      performance = performance_fixture()
      assert Performances.get_performance!(performance.id) == performance
    end

    test "create_performance/1 with valid data creates a performance" do
      valid_attrs = %{
        performance_type_id: performance_type_fixture().id,
        performer_id: performer_fixture().id,
        evening_id: evening_fixture().id
      }

      assert {:ok, %Performance{}} = Performances.create_performance(valid_attrs)
    end

    test "create_performance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Performances.create_performance(@invalid_attrs)
    end

    test "update_performance/2 with valid data updates the performance" do
      performance = performance_fixture()

      update_attrs = %{
        performance_type_id: performance_type_fixture().id,
        performer_id: performer_fixture().id,
        evening_id: evening_fixture(%{date: ~D[1999-01-01]}).id
      }

      assert {:ok, %Performance{}} = Performances.update_performance(performance, update_attrs)
    end

    test "update_performance/2 with invalid data returns error changeset" do
      performance = performance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Performances.update_performance(performance, @invalid_attrs)

      assert performance == Performances.get_performance!(performance.id)
    end

    test "delete_performance/1 deletes the performance" do
      performance = performance_fixture()
      assert {:ok, %Performance{}} = Performances.delete_performance(performance)
      assert_raise Ecto.NoResultsError, fn -> Performances.get_performance!(performance.id) end
    end

    test "delete_performance/1 deletes the performance and its votes" do
      performance = performance_fixture()
      user = user_fixture()
      vote = vote_fixture(%{user_id: user.id, performance_id: performance.id})

      assert {:ok, %Performance{}} = Performances.delete_performance(performance)
      assert_raise Ecto.NoResultsError, fn -> Votes.get_vote!(vote.id) end
    end

    test "change_performance/1 returns a performance changeset" do
      performance = performance_fixture()
      assert %Ecto.Changeset{} = Performances.change_performance(performance)
    end

    test "validates performance uniqueness" do
      %{
        performance_type_id: performance_type_id,
        performer_id: performer_id,
        evening_id: evening_id
      } = performance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Performances.create_performance(%{
                 performance_type_id: performance_type_id,
                 performer_id: performer_id,
                 evening_id: evening_id
               })
    end

    test "list_performances_of_evening/1 returns only the performances for the given evening and associations are loaded" do
      evening_1 = evening_fixture(%{date: ~D[2024-02-24], number: 1})
      evening_2 = evening_fixture(%{date: ~D[2024-02-25], number: 2})
      performance = performance_fixture(%{evening_id: evening_1.id})
      performance_fixture(%{evening_id: evening_2.id})
      user = user_fixture()
      _vote = vote_fixture(%{user_id: user.id, performance_id: performance.id})

      [retrieved_performance] = Performances.list_performances_of_evening(evening_1, user)

      assert performance.id == retrieved_performance.id
      assert Ecto.assoc_loaded?(retrieved_performance.performer)
      assert Ecto.assoc_loaded?(retrieved_performance.performance_type)
      assert Ecto.assoc_loaded?(retrieved_performance.votes)
      assert performance.performer_id == retrieved_performance.performer.id
      assert performance.performance_type_id == retrieved_performance.performance_type.id
      assert performance.id == retrieved_performance.votes |> hd() |> Map.get(:performance_id)
    end

    test "list_performances_of_evening/1 returns performances ordered by performer name" do
      evening = evening_fixture()
      performer_1 = performer_fixture(%{name: "B"})
      performer_2 = performer_fixture(%{name: "A"})
      performance_fixture(%{evening_id: evening.id, performer_id: performer_1.id})
      performance_fixture(%{evening_id: evening.id, performer_id: performer_2.id})
      user = user_fixture()

      [retrieved_performance_1, retrieved_performance_2] =
        Performances.list_performances_of_evening(evening, user)

      assert retrieved_performance_1.performer.name == "A"
      assert retrieved_performance_2.performer.name == "B"
    end

    test "list_performances_of_evening/1 returns performances with votes of current user only" do
      evening = evening_fixture()
      performance = performance_fixture(%{evening_id: evening.id})
      performance_2 = performance_fixture(%{evening_id: evening.id})
      user_1 = user_fixture()
      user_2 = user_fixture()
      vote_user_1 = vote_fixture(%{user_id: user_1.id, performance_id: performance.id})
      _vote_user_2 = vote_fixture(%{user_id: user_2.id, performance_id: performance.id})

      _vote_user_2_on_performance_2 =
        vote_fixture(%{user_id: user_2.id, performance_id: performance_2.id})

      retrieved_performances =
        Performances.list_performances_of_evening(evening, user_1)

      assert Enum.count(retrieved_performances) == 2
      [retrieved_performance_1, retrieved_performance_2] = retrieved_performances

      assert retrieved_performance_1.votes == [vote_user_1]
      assert retrieved_performance_2.votes == []
    end
  end
end
