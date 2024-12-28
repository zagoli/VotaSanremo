defmodule VotaSanremo.Juries do
  @moduledoc """
  The Juries context.
  """

  import Ecto.Query, warn: false
  alias VotaSanremo.Repo

  alias VotaSanremo.Juries.Jury
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Juries.JuriesComposition
  alias VotaSanremo.Accounts
  alias Ecto.Multi

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
  Returns the list of the ten juries with most members, ordered by the number of members in a decreasing order.
  If there are less than ten juries, returns all the juries.

  ## Examples

      iex> list_top_juries()
      [%{jury: %Jury{}, member_count: 10}, ...]
  """
  def list_top_juries do
    Jury
    |> join(:left, [j], jc in JuriesComposition, on: jc.jury_id == j.id)
    |> group_by([j], j.id)
    |> select([j, jc], %{
      jury: j,
      member_count: fragment("count (?) as member_count", jc.jury_id)
    })
    |> order_by(fragment("member_count DESC"))
    |> limit(10)
    |> Repo.all()
  end

  @doc """
  Returns the juries founded by a user.

  ## Examples

      iex> list_founded_juries(user)
      [%Jury{}, ...]
  """
  def list_founded_juries(user = %User{}) do
    Jury
    |> where(founder: ^user.id)
    |> Repo.all()
  end

  @doc """
  Returns the juries the user is a member of.

  ## Examples

      iex> list_member_juries(user)
      [%Jury{}, ...]
  """
  def list_member_juries(user = %User{}) do
    %User{juries: juries} = User |> Repo.get(user.id) |> Repo.preload(:juries)
    juries
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
  Gets a single jury.

  ## Examples

      iex> get_jury(123)
      %Jury{}

      iex> get_jury(456)
      nil

  """
  def get_jury(id), do: Repo.get(Jury, id)

  @doc """
  Gets a single jury with its members.

  ## Examples

      iex> get_jury_with_members(1)
      %Jury{members: [%User{}, ...]}

      iex> get_jury_with_members(-1)
      nil
  """
  def get_jury_with_members(id) do
    Repo.get(Jury, id) |> Repo.preload(:members)
  end

  @doc """
  Creates a jury.

  ## Examples

      iex> create_jury(%{name: value, founder: 1})
      {:ok, %Jury{}}

      iex> create_jury(%{name: bad_value, founder: -1})
      {:error, %Ecto.Changeset{}}

  """
  def create_jury(attrs \\ %{}) do
    %Jury{}
    |> Jury.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Adds a member to a jury.

  ## Examples

      iex> add_member(jury, user)
      {:ok, %JuriesComposition{}}

      iex> add_member(jury, bad_user)
      {:error, %Ecto.Changeset{}}

  """
  def add_member(%Jury{} = jury, %User{} = user) do
    %JuriesComposition{jury: jury, user: user}
    |> Repo.insert()
  end

  @doc """
  Removes a member from a jury.
  If the user is not a member of the jury, nothing happens.
  """
  def remove_member(%Jury{} = jury, %User{} = user) do
    JuriesComposition
    |> where([jc], jc.jury_id == ^jury.id and jc.user_id == ^user.id)
    |> Repo.delete_all()
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

  alias VotaSanremo.Juries.JuryInvite

  @doc """
  Returns the list of jury_invites.

  ## Examples

      iex> list_jury_invites()
      [%JuryInvite{}, ...]

  """
  def list_jury_invites do
    Repo.all(JuryInvite)
  end

  @doc """
  Gets a single jury_invite.

  Returns nil if the Jury invite does not exist.

  ## Examples

      iex> get_jury_invite!(123)
      %JuryInvite{}

      iex> get_jury_invite!(456)
      nil

  """
  def get_jury_invite!(id), do: Repo.get!(JuryInvite, id)

  def get_jury_invite_by_jury_and_user(%Jury{} = jury, %User{} = user) do
    JuryInvite
    |> where([ji], ji.jury_id == ^jury.id and ji.user_id == ^user.id)
    |> Repo.one()
  end

  @doc """
  Creates a jury_invite.

  ## Examples

      iex> create_jury_invite(%{field: value})
      {:ok, %JuryInvite{}}

      iex> create_jury_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_jury_invite(attrs \\ %{}) do
    %JuryInvite{}
    |> JuryInvite.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a jury_invite.

  ## Examples

      iex> update_jury_invite(jury_invite, %{field: new_value})
      {:ok, %JuryInvite{}}

      iex> update_jury_invite(jury_invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_jury_invite(%JuryInvite{} = jury_invite, attrs) do
    jury_invite
    |> JuryInvite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a jury_invite.

  ## Examples

      iex> delete_jury_invite(jury_invite)
      {:ok, %JuryInvite{}}

      iex> delete_jury_invite(jury_invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_jury_invite(%JuryInvite{} = jury_invite) do
    Repo.delete(jury_invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking jury_invite changes.

  ## Examples

      iex> change_jury_invite(jury_invite)
      %Ecto.Changeset{data: %JuryInvite{}}

  """
  def change_jury_invite(%JuryInvite{} = jury_invite, attrs \\ %{}) do
    JuryInvite.changeset(jury_invite, attrs)
  end

  @doc """
  Returns the list of pending invites for a jury.

  ## Examples

      iex> list_jury_pending_invites(jury)
      [%JuryInvite{}, ...]
  """
  def list_jury_pending_invites(%Jury{} = jury) do
    JuryInvite
    |> where([ji], ji.jury_id == ^jury.id and ji.status == :pending)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Returns the list of pending invites for a user.

  ## Examples

      iex> list_user_pending_invites(user)
      [%JuryInvite{}, ...]
  """
  def list_user_pending_invites(%User{} = user) do
    JuryInvite
    |> where([ji], ji.user_id == ^user.id and ji.status == :pending)
    |> preload(:jury)
    |> Repo.all()
  end

  @doc """
  Accepts a jury invite and adds the invited user to the jury.
  Only pending invites can be accepted, other statuses are ignored.

  ## Examples

      iex> accept_invite(%JuryInvite{status: :pending})
      {:ok, %{invite: %JuryInvite{status: :accepted}, membership: %JuriesComposition{}}}

      iex> accept_invite(%JuryInvite{status: :declined})
      nil
  """
  def accept_invite(%JuryInvite{status: :pending} = invite) do
    Multi.new()
    |> Multi.update(:invite, change_jury_invite(invite, %{status: :accepted}))
    |> Multi.run(:membership, fn _repo, %{invite: updated_invite} ->
      add_member(
        get_jury!(updated_invite.jury_id),
        Accounts.get_user!(updated_invite.user_id)
      )
    end)
    |> Repo.transaction()
  end

  def accept_invite(_invite), do: nil

  @doc """
  Declines a jury invite.
  Only pending invites can be declined, other statuses are ignored.

  ## Examples

      iex> decline_invite(%JuryInvite{status: :pending})
      {:ok, %JuryInvite{status: :declined}}

      iex> decline_invite(%JuryInvite{status: :accepted})
      nil
  """
  def decline_invite(%JuryInvite{status: :pending} = invite) do
    invite
    |> change_jury_invite(%{status: :declined})
    |> Repo.update()
  end

  @doc """
  Removes a member from a jury, and deletes the jury invite.


  ## Examples

      iex> member_exit(jury, user)
      :ok

      iex> member_exit(jury, bad_user)
      :error
  """
  def member_exit(%Jury{} = jury, %User{} = user) do
    with {_, _} <- remove_member(jury, user),
         invite when not is_nil(invite) <- get_jury_invite_by_jury_and_user(jury, user),
         {:ok, _} <- delete_jury_invite(invite) do
      :ok
    else
      _ -> :error
    end
  end

  @doc """
  Checks if a user is a member of a jury.
  """
  def member?(%Jury{} = jury, %User{} = user) do
    result =
      JuriesComposition
      |> where([jc], jc.jury_id == ^jury.id and jc.user_id == ^user.id)
      |> Repo.one()

    result != nil
  end
end
