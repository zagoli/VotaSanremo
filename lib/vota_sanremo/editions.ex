defmodule VotaSanremo.Editions do
  @moduledoc """
  The Editions context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Editions.Edition
  alias VotaSanremo.Editions.Edition.Queries

  @doc """
  Returns the list of editions.

  ## Examples

      iex> list_editions()
      [%Edition{}, ...]

  """
  def list_editions do
    Queries.all()
  end

  @doc """
  Returns the list of editions with the associated evenings.

  ##  Examples

      iex> list_editions_with_evenings()
      [%Edition{evenings: [%Evening{}, ...]}, ...]
  """
  def list_editions_with_evenings do
    Queries.all_with_evenings()
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
  Gets the edition with the latest start date.

  Raises `Ecto.NoResultsError` if no Edition exist.

  ## Examples

      iex> get_latest_edition!()
      %Edition{}

  """
  def get_latest_edition!(), do: Queries.latest_edition!()

  @doc """
  Gets the edition with the latest start date and associated evenings.

  Raises `Ecto.NoResultsError` if no Edition exist.

  ## Examples

      iex> get_latest_edition_with_evenings!()
      %Edition{evenings: [%Evening{}, ...]}

  """
  def get_latest_edition_with_evenings!(), do: Queries.latest_edition_with_evenings!()

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


  @doc """
  Retrieves a list of all edition names from the database.

  ## Examples

      iex> list_editions_names()
      ["Edition 1", "Edition 2", "Edition 3"]

  """
  def list_editions_names() do
    Edition
    |> select([e], e.name)
    |> Repo.all()
  end
end
