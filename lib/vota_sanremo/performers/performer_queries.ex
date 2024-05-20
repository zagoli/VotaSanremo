defmodule VotaSanremo.Performers.Performer.Queries do
  @moduledoc """
  This module provides additional queries for Performer.
  """
  import Ecto.Query
  alias VotaSanremo.Repo
  alias VotaSanremo.Performers.Performer

  defp base() do
    Performer
  end

  def all(query \\ base()) do
    query
    |> Repo.all()
  end

  def list_performers_avg_score_by_edition(edition_id) do
    base_for_performers_score_by_edition(edition_id)
    |> select_avg_score()
    |> all()
  end

  def list_performers_weighted_avg_score_by_edition(edition_id) do
    base_for_performers_score_by_edition(edition_id)
    |> select_weighted_avg_score()
    |> all()
  end

  defp base_for_performers_score_by_edition(edition_id) do
    from performer in "performers",
      join: performance in "performances",
      on: performance.performer_id == performer.id,
      join: vote in "votes",
      on: vote.performance_id == performance.id,
      join: evening in "evenings",
      on: evening.id == performance.evening_id,
      join: performance_type in "performance_types",
      on: performance.performance_type_id == performance_type.id,
      where: evening.edition_id == ^edition_id,
      group_by: [performer.name, performance_type.type]
  end

  defp select_avg_score(query) do
    query
    |> select([performer, _performance, vote, _evening, performance_type], %{
      performance_type: performance_type.type,
      name: performer.name,
      score: avg(vote.score)
    })
  end

  defp select_weighted_avg_score(query) do
    query
    |> select([performer, _performance, vote, _evening, performance_type], %{
      performance_type: performance_type.type,
      name: performer.name,
      score: avg(vote.score) * sum(vote.score)
    })
  end
end
