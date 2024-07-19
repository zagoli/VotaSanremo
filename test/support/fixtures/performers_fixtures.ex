defmodule VotaSanremo.PerformersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Performers` context.
  """

  @doc """
  Generate a unique performer name.
  """
  def unique_performer_name, do: "someName#{System.unique_integer([:positive])}"

  @doc """
  Generate a performer.
  """
  def performer_fixture(attrs \\ %{}) do
    {:ok, performer} =
      attrs
      |> Enum.into(%{
        name: unique_performer_name()
      })
      |> VotaSanremo.Performers.create_performer()

    performer
  end
end
