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
  Gets a single evening with preloaded performances and their associations.

  Raises `Ecto.NoResultsError` if the Evening does not exist.

  ## Examples

      iex> get_evening_with_performances!(123)
      %Evening{performances: [%Performance{performer: %Performer{}, performance_type: %PerformanceType{}}]}

      iex> get_evening_with_performances!(456)
      ** (Ecto.NoResultsError)

  """
  def get_evening_with_performances!(id) do
    Evening
    |> Repo.get!(id)
    |> Repo.preload(performances: [:performer, :performance_type])
  end

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

  @doc """
  Determines the voting status for a given evening.

  Returns one of three atoms:
    * `:before` - if current time is before votes start time
    * `:open` - if current time is between votes start and end time
    * `:after` - if current time is after votes end time

  ## Examples

      iex> get_voting_status(%Evening{votes_start: ~U[2024-02-06 20:00:00Z], votes_end: ~U[2024-02-06 23:59:59Z]})
      :before

  """
  def get_voting_status(%Evening{} = evening, %DateTime{} = current_time \\ DateTime.utc_now()) do
    cond do
      DateTime.before?(current_time, evening.votes_start) -> :before
      DateTime.after?(current_time, evening.votes_end) -> :after
      true -> :open
    end
  end
end
