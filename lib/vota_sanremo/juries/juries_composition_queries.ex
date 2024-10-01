defmodule VotaSanremo.Juries.JuriesComposition.Queries do
  @moduledoc """
  This module provides additional queries relating to Users and Juries.
  """
  import Ecto.Query
  alias VotaSanremo.Juries.Jury
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Repo

  defp base() do
    Jury
  end

  def list_founded_juries(user = %User{}) do
    base()
    |> where(founder: ^user.id)
    |> Repo.all()
  end

  def list_member_juries(%User{id: user_id}) do
    %User{juries: juries} = User |> Repo.get(user_id) |> Repo.preload(:juries)
    juries
  end
end
