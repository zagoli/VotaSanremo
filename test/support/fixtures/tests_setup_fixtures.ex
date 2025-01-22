defmodule VotaSanremo.TestSetupFixtures do
  import VotaSanremo.{
    PerformersFixtures,
    PerformancesFixtures,
    VotesFixtures,
    EditionsFixtures,
    EveningsFixtures,
    AccountsFixtures,
    JuriesFixtures
  }

  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Juries

  defp common_setup_for_avg_scores() do
    %{id: edition_id} = edition_fixture()
    %{id: performer_id, name: performer_name} = performer_fixture()
    %{id: first_performance_type_id, type: first_performance_type} = performance_type_fixture()

    %{id: second_performance_type_id, type: second_performance_type} =
      performance_type_fixture()

    %{id: first_evening_id} =
      evening_fixture(%{edition_id: edition_id, date: ~D[2024-12-13], number: 1})

    %{id: second_evening_id} =
      evening_fixture(%{edition_id: edition_id, date: ~D[2024-12-14], number: 2})

    %{id: first_performance_id} =
      performance_fixture(%{
        performer_id: performer_id,
        evening_id: first_evening_id,
        performance_type_id: first_performance_type_id
      })

    %{id: second_performance_id} =
      performance_fixture(%{
        performer_id: performer_id,
        evening_id: second_evening_id,
        performance_type_id: second_performance_type_id
      })

    {first_performance_id, second_performance_id, edition_id, performer_name,
     first_performance_type, second_performance_type}
  end

  @doc """
  Creates two performances of different types and evenings,
  and a vote for each performance for each number in the provided range.
  Returns a tuple with the edition id, performer name, first and second performance type.

  ## Examples

      iex> setup_for_avg_score_test(1..10)
      {1, "Performer", "Type 1", "Type 2"}
  """
  def setup_for_avg_score_tests(scores, multiplier \\ 1.0) do
    {first_performance_id, second_performance_id, edition_id, performer_name,
     first_performance_type, second_performance_type} = common_setup_for_avg_scores()

    Enum.each(scores, fn score ->
      vote_fixture(%{score: score, performance_id: first_performance_id, multiplier: multiplier})
      vote_fixture(%{score: score, performance_id: second_performance_id, multiplier: multiplier})
    end)

    {edition_id, performer_name, first_performance_type, second_performance_type}
  end

  @doc """
  Creates two performances of different types and evenings.
  For each performance, creates one vote for the given user with score five
  and one vote for another user with a score of one.
  Returns a tuple with the edition id, performer name, first and second performance type.
  """
  def setup_for_avg_score_by_user_test(%User{} = user, multiplier \\ 1.0) do
    {first_performance_id, second_performance_id, edition_id, performer_name,
     first_performance_type, second_performance_type} = common_setup_for_avg_scores()

    # Votes of the given user
    vote_fixture(%{
      score: 5.0,
      performance_id: first_performance_id,
      multiplier: multiplier,
      user_id: user.id
    })

    vote_fixture(%{
      score: 5.0,
      performance_id: second_performance_id,
      multiplier: multiplier,
      user_id: user.id
    })

    # Vote of different users
    vote_fixture(%{score: 1.0, performance_id: first_performance_id, multiplier: multiplier})
    vote_fixture(%{score: 1.0, performance_id: second_performance_id, multiplier: multiplier})

    {edition_id, performer_name, first_performance_type, second_performance_type}
  end

  @doc """
  Creates two performances of different types and evenings.
  For the `founder` creates a vote for the first performance wich is returned as first element.
  For the `member` creates a vote for the first performance which is returned as second element.
  It also creates a vote for the first performance for another user.
  """
  def setup_for_avg_score_by_jury_test(%User{} = founder, %User{} = member) do
    {first_performance_id, _second_performance_id, edition_id, performer_name,
     first_performance_type,
     _second_performance_type} =
      common_setup_for_avg_scores()

    founder_vote =
      vote_fixture(%{
        score: 10.0,
        performance_id: first_performance_id,
        user_id: founder.id
      })

    member_vote =
      vote_fixture(%{
        score: 5.0,
        performance_id: first_performance_id,
        user_id: member.id
      })

    # Vote for a different user
    vote_fixture(%{score: 1.0, performance_id: first_performance_id})

    {founder_vote, member_vote, edition_id, performer_name, first_performance_type}
  end

  @doc """
  Creates a user, a jury, an invite and a vote.
  Also add the created user as a member of another jury.
  """
  def setup_for_delete_user_test() do
    %{id: edition_id} = edition_fixture()
    %{id: performer_id} = performer_fixture()
    %{id: performance_type_id} = performance_type_fixture()

    %{id: evening_id} =
      evening_fixture(%{edition_id: edition_id, date: ~D[2024-12-13], number: 1})

    %{id: performance_id} =
      performance_fixture(%{
        performer_id: performer_id,
        evening_id: evening_id,
        performance_type_id: performance_type_id
      })

    user = user_fixture()
    founded_jury = jury_fixture(%{founder: user.id})
    jury = jury_fixture()
    Juries.add_member(jury, user)
    invited_user = user_fixture()
    invite = jury_invite_fixture(%{jury_id: founded_jury.id, user_id: invited_user.id})
    vote = vote_fixture(%{performance_id: performance_id})

    {user, founded_jury, jury, invite, vote}
  end
end
