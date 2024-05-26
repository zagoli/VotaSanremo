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
    {:ok, vote} =
      attrs
      |> Enum.into(%{
        multiplier: 1.0,
        score: 7.5,
        user_id:
          if not Map.has_key?(attrs, :user_id) do
            %{id: id} = AccountsFixtures.user_fixture()
            id
          end,
        performance_id:
          if not Map.has_key?(attrs, :performance_id) do
            %{id: id} = PerformancesFixtures.performance_fixture()
            id
          end
      })
      |> VotaSanremo.Votes.create_vote()

    vote
  end
end
