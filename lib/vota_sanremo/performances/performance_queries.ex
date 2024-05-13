defmodule VotaSanremo.Performances.Performance.Queries do
  @moduledoc """
  This module provides additional queries for Performance.
  """
  import Ecto.Query
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Repo
  alias VotaSanremo.Performances.Performance
  alias VotaSanremo.Evenings.Evening

  defp base() do
    Performance
  end

  def all(query \\ base()) do
    query
    |> Repo.all()
  end

  def list_performances_of_evening(%Evening{} = evening, %User{} = user) do
    base()
    |> join_performers()
    |> join_votes()
    |> filters(evening, user)
    |> order_by_performer()
    |> preload_performer()
    |> preload_votes()
    |> preload_performance_type()
    |> all()
  end

  defp join_performers(query) do
    query
    |> join(:inner, [performance], performer in assoc(performance, :performer))
  end

  defp join_votes(query) do
    query
    |> join(:left, [p, _], v in assoc(p, :votes))
  end

  defp filters(query, %Evening{} = evening, %User{} = user) do
    conditions = dynamic([p, _, v], p.evening_id == ^evening.id and (v.user_id == ^user.id or is_nil(v.user_id)))
    where(query, ^conditions)
  end

  defp order_by_performer(query) do
    query
    |> order_by([_, p, _], asc: p.name)
  end

  defp preload_performer(query) do
    query
    |> preload([_, p, _], performer: p)
  end

  defp preload_performance_type(query) do
    query
    |> preload(:performance_type)
  end

  defp preload_votes(query) do
    query
    |> preload([_, _, v], votes: v)
  end
end