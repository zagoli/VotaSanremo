defmodule VotaSanremo.VotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Votes` context.
  """
  alias VotaSanremo.{AccountsFixtures, PerformancesFixtures}

  @doc """
  Generate a vote.
  """
  def vote_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()
    performance = PerformancesFixtures.performance_fixture()
    {:ok, vote} =
      attrs
      |> Enum.into(%{
        multiplier: 1.0,
        score: 7.5,
        user_id: user.id,
        performance_id: performance.id
      })
      |> VotaSanremo.Votes.create_vote()

    vote
  end
end
