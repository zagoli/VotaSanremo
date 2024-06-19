defmodule VotaSanremo.UserSearch.Username do
  @moduledoc """
  This module provides a schema and changeset used to validate input for the user search.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :username, :string
  end

  @doc """
  Validates a username for user search
  """
  def changeset(%__MODULE__{} = username, attrs) do
    username
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> validate_format(:username, ~r"^[a-zA-Z0-9]+$", message: "must contain only letters and numbers")
  end
end
