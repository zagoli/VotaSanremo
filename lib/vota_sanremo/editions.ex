defmodule VotaSanremo.Editions do
  @moduledoc """
  The Editions context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Editions.Edition

  @doc """
  Returns the list of editions.

  ## Examples

      iex> list_editions()
      [%Edition{}, ...]

  """
  def list_editions do
    Repo.all(Edition)
  end

  @doc """
  Gets a single edition.

  Raises `Ecto.NoResultsError` if the Edition does not exist.

  ## Examples

      iex> get_edition!(123)
      %Edition{}

      iex> get_edition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_edition!(id), do: Repo.get!(Edition, id)

  @doc """
  Creates a edition.

  ## Examples

      iex> create_edition(%{field: value})
      {:ok, %Edition{}}

      iex> create_edition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_edition(attrs \\ %{}) do
    %Edition{}
    |> Edition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a edition.

  ## Examples

      iex> update_edition(edition, %{field: new_value})
      {:ok, %Edition{}}

      iex> update_edition(edition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_edition(%Edition{} = edition, attrs) do
    edition
    |> Edition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a edition.

  ## Examples

      iex> delete_edition(edition)
      {:ok, %Edition{}}

      iex> delete_edition(edition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_edition(%Edition{} = edition) do
    Repo.delete(edition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking edition changes.

  ## Examples

      iex> change_edition(edition)
      %Ecto.Changeset{data: %Edition{}}

  """
  def change_edition(%Edition{} = edition, attrs \\ %{}) do
    Edition.changeset(edition, attrs)
  end
end
