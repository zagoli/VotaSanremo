defmodule VotaSanremo.TestSetupFixtures do
  import VotaSanremo.{
    PerformersFixtures,
    PerformancesFixtures,
    VotesFixtures,
    EditionsFixtures,
    EveningsFixtures
  }

  @doc """
  Creates two performances of different type and evenings, and a vote for each performance for each number in the provided range.
  Returns a tuple with the edition id, performer name, first and second performance type.

  ## Examples

      iex> setup_for_avg_score_test(1..10)
      {1, "Performer", "Type 1", "Type 2"}
  """
  def setup_for_avg_score_tests(scores, multiplier \\ 1.0) do
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

    Enum.each(scores, fn score ->
      vote_fixture(%{score: score, performance_id: first_performance_id, multiplier: multiplier})
      vote_fixture(%{score: score, performance_id: second_performance_id, multiplier: multiplier})
    end)

    {edition_id, performer_name, first_performance_type, second_performance_type}
  end
end
