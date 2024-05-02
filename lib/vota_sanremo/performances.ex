defmodule VotaSanremo.Performances do
  @moduledoc """
  The Performances context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Performances.PerformanceType

  @doc """
  Returns the list of performancetypes.

  ## Examples

      iex> list_performancetypes()
      [%PerformanceType{}, ...]

  """
  def list_performancetypes do
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
end
