defmodule VotaSanremo.JuriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Juries` context.
  """
  alias VotaSanremo.AccountsFixtures

  @doc """
  Generate a unique jury name.
  """
  def unique_jury_name, do: "someName#{System.unique_integer([:positive])}"

  @doc """
  Generate a jury.
  """
  def jury_fixture(attrs \\ %{}) do
    %{id: founder_id} = AccountsFixtures.user_fixture()

    {:ok, jury} =
      attrs
      |> Enum.into(%{
        name: unique_jury_name(),
        founder: founder_id
      })
      |> VotaSanremo.Juries.create_jury()

    jury
  end

  @doc """
  Generate a jury_invite.
  """
  def jury_invite_fixture(attrs \\ %{}) do
    %{id: user_id} = AccountsFixtures.user_fixture()
    %{id: jury_id} = jury_fixture()

    {:ok, jury_invite} =
      attrs
      |> Enum.into(%{
        status: :pending,
        user_id: user_id,
        jury_id: jury_id
      })
      |> VotaSanremo.Juries.create_jury_invite()

    jury_invite
  end
end
