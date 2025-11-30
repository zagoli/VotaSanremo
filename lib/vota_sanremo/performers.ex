defmodule VotaSanremo.Performers do
  @moduledoc """
  The Performers context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Performers.Performer
  alias VotaSanremo.Performers.Performer.Queries
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Juries.Jury

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
  def delete_performer(%Performer{} = performer), do: Repo.delete(performer)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking performer changes.

  ## Examples

      iex> change_performer(performer)
      %Ecto.Changeset{data: %Performer{}}

  """
  def change_performer(%Performer{} = performer, attrs \\ %{}),
    do: Performer.changeset(performer, attrs)

  @doc """
  Returns the average scores of performers as maps. These maps contain the performer name, the performance type
  and the average score the performer got in the performance type in the edition corresponding to edition_id.

  ## Examples

      iex> list_performers_avg_score_by_edition(1)
      [%{name: "Performer_1", performance_type: "Song", score: 12.33},
      %{name: "Performer_1", performance_type: "Song", score: 12.33}]
  """
  def list_performers_avg_score_by_edition(edition_id) when is_integer(edition_id),
    do: Queries.list_performers_avg_score_by_edition(edition_id)

  @doc """
  Get the sum of all the scores of a performer, scaled from 0 to 100.
  Returns a list of maps containing the performer name, the performance type
  and the scaled score the performer got in the `performance_type` in the edition corresponding to `edition_id`.

  ## Examples

      iex> list_performers_weighted_avg_score_by_edition(1)
      [%{name: "Performer_1", performance_type: "Song", score: 50},
      %{name: "Performer_1", performance_type: "Song", score: 100}]
  """
  def list_performers_weighted_avg_score_by_edition(edition_id) when is_integer(edition_id) do
    sum_scores = Queries.list_performers_sum_score_by_edition(edition_id)
    scale_scores(sum_scores)
  end

  @doc """
  Same as the version without `user` as the parameter, but only with the votes of the given `user`.
  """
  def list_performers_avg_score_by_edition_by_user(edition_id, %User{} = user)
      when is_integer(edition_id),
      do: Queries.list_performers_avg_score_by_edition_by_user(edition_id, user)

  @doc """
  Same as the version without `jury` as the parameter, but only with the votes of the users who are members of the given `jury`.
  """
  def list_performers_avg_score_by_edition_by_jury(edition_id, %Jury{} = jury)
      when is_integer(edition_id),
      do: Queries.list_performers_avg_score_by_edition_by_jury(edition_id, jury)

  @doc """
  Same as the version without `jury` as the parameter, but only with the votes of the users who are members of the given `jury`.
  """
  def list_performers_weighted_score_by_edition_by_jury(edition_id, %Jury{} = jury)
      when is_integer(edition_id) do
    sum_scores = Queries.list_performers_sum_score_by_edition_by_jury(edition_id, jury)
    scale_scores(sum_scores)
  end

  defp scale_scores([]), do: []

  defp scale_scores(scores) when is_list(scores) do
    max = get_max(scores)
    scores |> Enum.map(&%{&1 | score: scale_score(&1, max)})
  end

  defp get_max(scores) when is_list(scores) do
    scores
    |> Enum.map(& &1.score)
    |> Enum.reject(&(&1 == nil))
    |> Enum.max(&Kernel.>=/2, fn -> nil end)
  end

  defp scale_score(%{score: nil}, _), do: nil
  # Returns a float
  defp scale_score(%{score: score}, max), do: score / max * 100
end
