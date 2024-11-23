defmodule VotaSanremo.Evenings do
  @moduledoc """
  The Evenings context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Evenings.Evening

  @doc """
  Returns the list of evenings.

  ## Examples

      iex> list_evenings()
      [%Evening{}, ...]

  """
  def list_evenings do
    Repo.all(Evening)
  end

  @doc """
  Gets a single evening.

  Raises `Ecto.NoResultsError` if the Evening does not exist.

  ## Examples

      iex> get_evening!(123)
      %Evening{}

      iex> get_evening!(456)
      ** (Ecto.NoResultsError)

  """
  def get_evening!(id), do: Repo.get!(Evening, id)

  @doc """
  Creates a evening.

  ## Examples

      iex> create_evening(%{field: value})
      {:ok, %Evening{}}

      iex> create_evening(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_evening(attrs \\ %{}) do
    %Evening{}
    |> Evening.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a evening.

  ## Examples

      iex> update_evening(evening, %{field: new_value})
      {:ok, %Evening{}}

      iex> update_evening(evening, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_evening(%Evening{} = evening, attrs) do
    evening
    |> Evening.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a evening.

  ## Examples

      iex> delete_evening(evening)
      {:ok, %Evening{}}

      iex> delete_evening(evening)
      {:error, %Ecto.Changeset{}}

  """
  def delete_evening(%Evening{} = evening) do
    Repo.delete(evening)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking evening changes.

  ## Examples

      iex> change_evening(evening)
      %Ecto.Changeset{data: %Evening{}}

  """
  def change_evening(%Evening{} = evening, attrs \\ %{}) do
    Evening.changeset(evening, attrs)
  end

  @doc """
  Retrieves the date of the most recent evening from the database.

  ## Examples

      iex> get_latest_evening_date()
      ~D[2024-02-10]

      iex> get_latest_evening_date() # When no records exist
      nil
  """
  def get_latest_evening_date do
    Evening
    |> select([e], max(e.date))
    |> Repo.one()
  end
end
