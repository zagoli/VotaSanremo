defmodule VotaSanremo.UserSearch do
  @moduledoc """
  Validation for user search
  """
  alias VotaSanremo.UserSearch.Username

  @doc """
  Returns a changeset to validate a username in the user search
  """
  def change_username(attrs \\ %{}) do
    Username.changeset(%Username{}, attrs)
  end

end
