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
    base()
    |> join_performances()
    |> join_votes()
    |> join_evenings()
    |> join_performance_types()
    |> filter_by_edition(edition_id)
    |> group_by_performer_and_performance_type()
    |> select_avg_score()
    |> all()
  end

  def list_performers_weighted_avg_score_by_edition(edition_id) do
    base()
    |> join_performances()
    |> join_votes()
    |> join_evenings()
    |> join_performance_types()
    |> filter_by_edition(edition_id)
    |> group_by_performer_and_performance_type()
    |> select_weighted_avg_score()
    |> all()
  end

  def list_performers_avg_score_by_edition_by_user(edition_id, user) do
    base()
    |> join_performances()
    |> join_votes_of_user(user)
    |> join_evenings()
    |> join_performance_types()
    |> filter_by_edition(edition_id)
    |> group_by_performer_and_performance_type()
    |> select_avg_score()
    |> all()
  end

  def list_performers_avg_score_by_edition_by_jury(edition_id, jury) do
    base()
    |> join_performances()
    |> join_votes_of_jury(jury)
    |> join_evenings()
    |> join_performance_types()
    |> filter_by_edition(edition_id)
    |> group_by_performer_and_performance_type()
    |> select_avg_score()
    |> all()
  end

  def list_performers_weighted_score_by_edition_by_jury(edition_id, jury) do
    base()
    |> join_performances()
    |> join_votes_of_jury(jury)
    |> join_evenings()
    |> join_performance_types()
    |> filter_by_edition(edition_id)
    |> group_by_performer_and_performance_type()
    |> select_weighted_avg_score()
    |> all()
  end

  defp join_performances(query) do
    query |> join(:inner, [p], performance in assoc(p, :performances))
  end

  defp join_votes(query) do
    query |> join(:left, [p, pp], v in assoc(pp, :votes))
  end

  defp join_votes_of_user(query, user) do
    query
    |> join(:left, [p, pp], v in assoc(pp, :votes),
      on: pp.id == v.performance_id and v.user_id == ^user.id
    )
  end

  defp join_votes_of_jury(query, jury) do
    query
    |> join(:left, [p, pp], v in assoc(pp, :votes), on: pp.id == v.performance_id)
    |> join(:inner, [p, pp, v], u in assoc(v, :user), on: v.user_id == u.id)
    |> join(:inner, [p, pp, v, u], j in assoc(u, :juries), on: j.id == ^jury.id)
  end

  defp join_evenings(query) do
    query |> join(:inner, [p, pp, v], e in assoc(pp, :evening))
  end

  defp join_performance_types(query) do
    query |> join(:inner, [p, pp, v, e], pt in assoc(pp, :performance_type))
  end

  defp filter_by_edition(query, edition_id) do
    query |> where([p, ..., e, pt], e.edition_id == ^edition_id)
  end

  defp group_by_performer_and_performance_type(query) do
    query |> group_by([p, ..., pt], [p.name, pt.type])
  end

  defp select_avg_score(query) do
    query
    |> select([performer, _, vote, ..., performance_type], %{
      performance_type: performance_type.type,
      name: performer.name,
      score: avg(vote.score * vote.multiplier)
    })
  end

  defp select_weighted_avg_score(query) do
    query
    |> select([performer, _, vote, ..., performance_type], %{
      performance_type: performance_type.type,
      name: performer.name,
      score: avg(vote.score * vote.multiplier) * sum(vote.score)
    })
  end
end
