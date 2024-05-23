defmodule VotaSanremo.Editions.Edition.Queries do
  @moduledoc """
  This module provides additional queries for Edition.
  """
  import Ecto.Query
  alias VotaSanremo.Repo
  alias VotaSanremo.Editions.Edition
  alias VotaSanremo.Evenings.Evening

  defp base() do
    Edition
  end

  def all(query \\ base()) do
    query
    |> Repo.all()
  end

  def latest_edition!(query \\ base()) do
    query
    |> where(start_date: subquery(get_latest_edition_start_date()))
    |> Repo.one!()
  end

  def latest_edition_with_evenings!(query \\ base()) do
    query
    |> preload_evenings()
    |> latest_edition!()
  end

  def all_with_evenings(query \\ base()) do
    query
    |> preload_evenings()
    |> all()
  end

  defp get_latest_edition_start_date() do
    base()
    |> select([edition], max(edition.start_date))
  end

  defp preload_evenings(query) do
    ordered_evenings = Evening |> order_by(:number)

    query
    |> preload(evenings: ^ordered_evenings)
  end
end
