defmodule VotaSanremo.VotesTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Votes

  describe "votes" do
    alias VotaSanremo.Votes.Vote

    import VotaSanremo.{VotesFixtures, AccountsFixtures, PerformancesFixtures, EveningsFixtures}

    @invalid_attrs %{score: nil, multiplier: nil, user_id: nil, performance_id: nil}

    test "list_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Votes.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Votes.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      valid_attrs = %{
        score: 1.5,
        multiplier: 1.0,
        user_id: user_fixture().id,
        performance_id: performance_fixture().id
      }

      assert {:ok, %Vote{} = vote} = Votes.create_vote(valid_attrs)
      assert vote.score == 1.5
      assert vote.multiplier == 1.0
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Votes.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()

      another_evening = evening_fixture(%{date: ~D[1999-01-01]})

      update_attrs = %{
        score: 5.5,
        multiplier: 1.0,
        user_id: user_fixture().id,
        performance_id: performance_fixture(%{evening_id: another_evening.id}).id
      }

      assert {:ok, %Vote{} = vote} = Votes.update_vote(vote, update_attrs)
      assert vote.score == 5.5
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Votes.update_vote(vote, @invalid_attrs)
      assert vote == Votes.get_vote!(vote.id)
    end

    test "create_or_update_vote/1 creates a new vote and updates it with new score and multiplier" do
      %{id: user_id} = user_fixture()
      %{id: performance_id} = performance_fixture()

      # Creation
      vote_attrs = %{
        score: 5.0,
        multiplier: 1.0,
        user_id: user_id,
        performance_id: performance_id
      }

      assert {:ok, %Vote{} = vote} = Votes.create_or_update_vote(vote_attrs)
      assert vote.score == 5.0
      assert vote.multiplier == 1.0

      # Update
      update_vote_attrs = vote_attrs |> Map.put(:score, 6.0) |> Map.put(:multiplier, 2.0)
      assert {:ok, %Vote{} = vote} = Votes.create_or_update_vote(update_vote_attrs)
      assert vote.score == 6.0
      assert vote.multiplier == 2.0
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Votes.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Votes.get_vote!(vote.id) end
    end

    test "delete_vote/2 deletes the vote given performance and user" do
      vote = vote_fixture()
      assert :ok = Votes.delete_vote(vote.performance_id, vote.user_id)
      assert_raise Ecto.NoResultsError, fn -> Votes.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Votes.change_vote(vote)
    end

    test "validates vote uniqueness" do
      %{
        user_id: user_id,
        performance_id: performance_id
      } = vote_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Votes.create_vote(%{
                 score: 1,
                 multiplier: 1,
                 user_id: user_id,
                 performance_id: performance_id
               })
    end

    test "accept only valid scores" do
      base_vote_attrs = %{
        score: 1,
        multiplier: 1,
        user_id: user_fixture().id,
        performance_id: performance_fixture().id
      }

      assert {:error, %Ecto.Changeset{}} = Votes.create_vote(%{base_vote_attrs | score: -1})
      assert {:error, %Ecto.Changeset{}} = Votes.create_vote(%{base_vote_attrs | score: 11})
      assert {:error, %Ecto.Changeset{}} = Votes.create_vote(%{base_vote_attrs | score: 8.34})
    end
  end
end
