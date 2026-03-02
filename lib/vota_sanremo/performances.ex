defmodule VotaSanremo.Performances do
  @moduledoc """
  The Performances context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Performances.PerformanceType
  alias VotaSanremo.Performances.Performance
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Evenings.Evening

  @doc """
  Returns the list of performance types.

  ## Examples

      iex> list_performance_types()
      [%PerformanceType{}, ...]

  """
  def list_performance_types do
    Repo.all(PerformanceType)
  end

  @doc """
  Gets a single performance_type.

  Raises `Ecto.NoResultsError` if the Performance type does not exist.

  ## Examples

      iex> get_performance_type!(123)
      %PerformanceType{}

      iex> get_performance_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_performance_type!(id), do: Repo.get!(PerformanceType, id)

  @doc """
  Creates a performance_type.

  ## Examples

      iex> create_performance_type(%{field: value})
      {:ok, %PerformanceType{}}

      iex> create_performance_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_performance_type(attrs \\ %{}) do
    %PerformanceType{}
    |> PerformanceType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a performance_type.

  ## Examples

      iex> update_performance_type(performance_type, %{field: new_value})
      {:ok, %PerformanceType{}}

      iex> update_performance_type(performance_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_performance_type(%PerformanceType{} = performance_type, attrs) do
    performance_type
    |> PerformanceType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a performance_type.

  ## Examples

      iex> delete_performance_type(performance_type)
      {:ok, %PerformanceType{}}

      iex> delete_performance_type(performance_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_performance_type(%PerformanceType{} = performance_type) do
    Repo.delete(performance_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking performance_type changes.

  ## Examples

      iex> change_performance_type(performance_type)
      %Ecto.Changeset{data: %PerformanceType{}}

  """
  def change_performance_type(%PerformanceType{} = performance_type, attrs \\ %{}) do
    PerformanceType.changeset(performance_type, attrs)
  end

  alias VotaSanremo.Performances.Performance

  @doc """
  Returns the list of performances.

  ## Examples

      iex> list_performances()
      [%Performance{}, ...]

  """
  def list_performances do
    Performance.Queries.all()
  end

  @doc """
  Returns the list of performances associated with an Evening, with the associated user votes.

  ## Examples

      iex> list_performances_of_evening(%Evening{}, %User{})
      [%Performance{}, ...]

  """
  def list_performances_of_evening(%Evening{} = evening, %User{} = user) do
    Performance.Queries.list_performances_of_evening(evening, user)
  end

  @doc """
  Gets a single performance.

  Raises `Ecto.NoResultsError` if the Performance does not exist.

  ## Examples

      iex> get_performance!(123)
      %Performance{}

      iex> get_performance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_performance!(id), do: Repo.get!(Performance, id)

  @doc """
  Creates a performance.

  ## Examples

      iex> create_performance(%{field: value})
      {:ok, %Performance{}}

      iex> create_performance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_performance(attrs \\ %{}) do
    %Performance{}
    |> Performance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a performance.

  ## Examples

      iex> update_performance(performance, %{field: new_value})
      {:ok, %Performance{}}

      iex> update_performance(performance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_performance(%Performance{} = performance, attrs) do
    performance
    |> Performance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a performance.

  ## Examples

      iex> delete_performance(performance)
      {:ok, %Performance{}}

      iex> delete_performance(performance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_performance(%Performance{} = performance) do
    Repo.delete(performance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking performance changes.

  ## Examples

      iex> change_performance(performance)
      %Ecto.Changeset{data: %Performance{}}

  """
  def change_performance(%Performance{} = performance, attrs \\ %{}) do
    Performance.changeset(performance, attrs)
  end

  @doc """
  Copies all performances from a source evening to a target evening.
  Deletes all existing performances of the target evening first, then
  creates new performances copying performer_id and performance_type_id
  from the source evening's performances.

  ## Examples

      iex> copy_performances_from_evening(%Evening{}, %Evening{})
      {:ok, [%Performance{}, ...]}

      iex> copy_performances_from_evening(%Evening{id: bad_id}, %Evening{})
      {:error, reason}

  """
  def copy_performances_from_evening(%Evening{} = source_evening, %Evening{} = target_evening) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    delete_query =
      from p in Performance, where: p.evening_id == ^target_evening.id

    insert_query =
      from p in Performance,
        where: p.evening_id == ^source_evening.id,
        select: %{
          performer_id: p.performer_id,
          performance_type_id: p.performance_type_id,
          evening_id: ^target_evening.id,
          inserted_at: ^now,
          updated_at: ^now
        }

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete, delete_query)
    |> Ecto.Multi.insert_all(:insert, Performance, insert_query, returning: true)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert: {_count, inserted}}} -> {:ok, inserted}
      {:error, _op, reason, _changes} -> {:error, reason}
    end
  end
end
