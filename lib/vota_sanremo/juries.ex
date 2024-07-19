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
end
