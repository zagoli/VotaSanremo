defmodule VotaSanremo.Performers do
  @moduledoc """
  The Performers context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Performers.Performer
  alias VotaSanremo.Performers.Performer.Queries
  alias VotaSanremo.Accounts.User

  @doc """
  Returns the list of performers.

  ## Examples

      iex> list_performers()
      [%Performer{}, ...]

  """
  def list_performers do
    Queries.all()
  end

  @doc """
  Gets a single performer.

  Raises `Ecto.NoResultsError` if the Performer does not exist.

  ## Examples

      iex> get_performer!(123)
      %Performer{}

      iex> get_performer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_performer!(id), do: Repo.get!(Performer, id)

  @doc """
  Creates a performer.

  ## Examples

      iex> create_performer(%{field: value})
      {:ok, %Performer{}}

      iex> create_performer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_performer(attrs \\ %{}) do
    %Performer{}
    |> Performer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a performer.

  ## Examples

      iex> update_performer(performer, %{field: new_value})
      {:ok, %Performer{}}

      iex> update_performer(performer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_performer(%Performer{} = performer, attrs) do
    performer
    |> Performer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a performer.

  ## Examples

      iex> delete_performer(performer)
      {:ok, %Performer{}}

      iex> delete_performer(performer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_performer(%Performer{} = performer) do
    Repo.delete(performer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking performer changes.

  ## Examples

      iex> change_performer(performer)
      %Ecto.Changeset{data: %Performer{}}

  """
  def change_performer(%Performer{} = performer, attrs \\ %{}) do
    Performer.changeset(performer, attrs)
  end

  @doc """
  Returns the average scores of performers as maps. These maps contain the performer name, the performance type
  and the average score the performer got in the performance type in the edition corresponding to edition_id.

  ## Examples

      iex> list_performers_avg_score_by_edition(1)
      [%{name: "Performer_1", performance_type: "Song", score: 12.33},
      %{name: "Performer_1", performance_type: "Song", score: 12.33}]
  """
  def list_performers_avg_score_by_edition(edition_id) when is_integer(edition_id) do
    Queries.list_performers_avg_score_by_edition(edition_id)
  end

  @doc """
  Returns the average weighted scores of performers as maps.
  The average score is multiplied by the sum of the scores.
  These maps contain the performer name, the performance type
  and the weighted average score the performer got in the performance
  type in the edition corresponding to edition_id.

  ## Examples

      iex> list_performers_weighted_avg_score_by_edition(1)
      [%{name: "Performer_1", performance_type: "Song", score: 12.33},
      %{name: "Performer_1", performance_type: "Song", score: 12.33}]
  """
  def list_performers_weighted_avg_score_by_edition(edition_id) when is_integer(edition_id) do
    Queries.list_performers_weighted_avg_score_by_edition(edition_id)
  end

  @doc """
  Same as the version without `user` as the parameter, but with only the votes of the given `user`.
  """
  def list_performers_avg_score_by_edition_by_user(edition_id, %User{} = user)
      when is_integer(edition_id) do
    Queries.list_performers_avg_score_by_edition_by_user(edition_id, user)
  end

  @doc """
  Same as the version without `user` as the parameter, but with only the votes of the given `user`.
  """
  def list_performers_weighted_avg_score_by_edition_by_user(edition_id, %User{} = user)
      when is_integer(edition_id) do
    Queries.list_performers_weighted_avg_score_by_edition_by_user(edition_id, user)
  end
end
