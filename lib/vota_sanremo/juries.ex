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

  alias VotaSanremo.Juries.JuryInvitation

  @doc """
  Returns the list of jury_invitations.

  ## Examples

      iex> list_jury_invitations()
      [%JuryInvitation{}, ...]

  """
  def list_jury_invitations do
    Repo.all(JuryInvitation)
  end

  @doc """
  Gets a single jury_invitation.

  Raises `Ecto.NoResultsError` if the Jury invitation does not exist.

  ## Examples

      iex> get_jury_invitation!(123)
      %JuryInvitation{}

      iex> get_jury_invitation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_jury_invitation!(id), do: Repo.get!(JuryInvitation, id)

  @doc """
  Creates a jury_invitation.

  ## Examples

      iex> create_jury_invitation(%{field: value})
      {:ok, %JuryInvitation{}}

      iex> create_jury_invitation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_jury_invitation(attrs \\ %{}) do
    %JuryInvitation{}
    |> JuryInvitation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a jury_invitation.

  ## Examples

      iex> update_jury_invitation(jury_invitation, %{field: new_value})
      {:ok, %JuryInvitation{}}

      iex> update_jury_invitation(jury_invitation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_jury_invitation(%JuryInvitation{} = jury_invitation, attrs) do
    jury_invitation
    |> JuryInvitation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a jury_invitation.

  ## Examples

      iex> delete_jury_invitation(jury_invitation)
      {:ok, %JuryInvitation{}}

      iex> delete_jury_invitation(jury_invitation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_jury_invitation(%JuryInvitation{} = jury_invitation) do
    Repo.delete(jury_invitation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking jury_invitation changes.

  ## Examples

      iex> change_jury_invitation(jury_invitation)
      %Ecto.Changeset{data: %JuryInvitation{}}

  """
  def change_jury_invitation(%JuryInvitation{} = jury_invitation, attrs \\ %{}) do
    JuryInvitation.changeset(jury_invitation, attrs)
  end

  @doc """
  Returns the list of pending invitations for a jury.

  ## Examples

      iex> list_jury_pending_invitations(jury)
      [%JuryInvitation{}, ...]
  """
  def list_jury_pending_invitations(%Jury{} = jury) do
    JuryInvitation
    |> where([ji], ji.jury_id == ^jury.id and ji.status == :pending)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Returns the list of pending invitations for a user.

  ## Examples

      iex> list_user_pending_invitations(user)
      [%JuryInvitation{}, ...]
  """
  def list_user_pending_invitations(%User{} = user) do
    JuryInvitation
    |> where([ji], ji.user_id == ^user.id and ji.status == :pending)
    |> preload(:jury)
    |> Repo.all()
  end

  @doc """
  Accepts a jury invitation and adds the invited user to the jury.
  Only pending invitations can be accepted, other statuses are ignored.

  ## Examples

      iex> accept_invitation(%JuryInvitation{status: :pending})
      {:ok, %{invitation: %JuryInvitation{status: :accepted}, membership: %JuriesComposition{}}}

      iex> accept_invitation(%JuryInvitation{status: :declined})
      nil
  """
  def accept_invitation(%JuryInvitation{status: :pending} = invitation) do
    Multi.new()
    |> Multi.update(:invitation, change_jury_invitation(invitation, %{status: :accepted}))
    |> Multi.run(:membership, fn _repo, %{invitation: updated_invitation} ->
      add_member(
        get_jury!(updated_invitation.jury_id),
        Accounts.get_user!(updated_invitation.user_id)
      )
    end)
    |> Repo.transaction()
  end

  def accept_invitation(_invitation), do: nil

  @doc """
  Declines a jury invitation.
  Only pending invitations can be declined, other statuses are ignored.

  ## Examples

      iex> decline_invitation(%JuryInvitation{status: :pending})
      {:ok, %JuryInvitation{status: :declined}}

      iex> decline_invitation(%JuryInvitation{status: :accepted})
      nil
  """
  def decline_invitation(%JuryInvitation{status: :pending} = invitation) do
    invitation
    |> change_jury_invitation(%{status: :declined})
    |> Repo.update()
  end
end
