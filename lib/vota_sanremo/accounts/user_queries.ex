defmodule VotaSanremo.Accounts.User.Queries do
  @moduledoc """
  This module provides additional queries for User.
  """
  import Ecto.Query
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Repo

  defp base() do
    User
  end

  @doc """
  List users with username starting with `username`. Limited to 100 matches.
  In the future it would be nice to use PostgreSQL's `fuzzystrmatch`
  """
  def list_users_by_username(username) when is_binary(username) do
    like = "#{username}%"

    base()
    |> where([u], ilike(u.username, ^like))
    |> order_by(desc: :username)
    |> limit(100)
    |> Repo.all()
  end
end
