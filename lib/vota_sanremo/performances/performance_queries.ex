defmodule VotaSanremo.Performances.Performance.Queries do
  @moduledoc """
  This module provides additional queries for Performance.
  """
  import Ecto.Query
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

  def list_performances_of_evening(%Evening{} = evening) do
    base()
    |> preload_performer_with_join()
    |> preload_performance_type()
    |> filter_by_evening(evening)
    |> order_by_performer()
    |> all()
  end

  defp filter_by_evening(query, %Evening{} = evening) do
    query
    |> join(:inner, [p], e in assoc(p, :evening))
    |> where([p, _, e], e.id == ^evening.id)
  end

  defp preload_performer_with_join(query) do
    query
    |> join(:inner, [performance], performer in assoc(performance, :performer))
    |> preload([performance, performer], performer: performer)
  end

  defp order_by_performer(query) do
    query
    |> order_by([performance, performer, evening], asc: performer.name)
  end

  defp preload_performance_type(query) do
    query
    |> preload(:performance_type)
  end
end
