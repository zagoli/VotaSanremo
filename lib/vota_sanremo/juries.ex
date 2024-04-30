defmodule VotaSanremo.Juries do
  @moduledoc """
  The Juries context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Juries.Jury

  @doc """
  Returns the list of juries.

  ## Examples

      iex> list_juries()
      [%Jury{}, ...]

  """
  def list_juries do
    Repo.all(Jury)
  end

  @doc """
  Gets a single jury.

  Raises `Ecto.NoResultsError` if the Jury does not exist.

  ## Examples

      iex> get_jury!(123)
      %Jury{}

      iex> get_jury!(456)
      ** (Ecto.NoResultsError)

  """
  def get_jury!(id), do: Repo.get!(Jury, id)

  @doc """
  Creates a jury.

  ## Examples

      iex> create_jury(%{field: value})
      {:ok, %Jury{}}

      iex> create_jury(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_jury(attrs \\ %{}) do
    %Jury{}
    |> Jury.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a jury.

  ## Examples

      iex> update_jury(jury, %{field: new_value})
      {:ok, %Jury{}}

      iex> update_jury(jury, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_jury(%Jury{} = jury, attrs) do
    jury
    |> Jury.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a jury.

  ## Examples

      iex> delete_jury(jury)
      {:ok, %Jury{}}

      iex> delete_jury(jury)
      {:error, %Ecto.Changeset{}}

  """
  def delete_jury(%Jury{} = jury) do
    Repo.delete(jury)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking jury changes.

  ## Examples

      iex> change_jury(jury)
      %Ecto.Changeset{data: %Jury{}}

  """
  def change_jury(%Jury{} = jury, attrs \\ %{}) do
    Jury.changeset(jury, attrs)
  end
end
