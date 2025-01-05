defmodule VotaSanremo.EditionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Editions` context.
  """

  @doc """
  Generate a edition.
  """
  def edition_fixture(attrs \\ %{}) do
    {:ok, edition} =
      attrs
      |> Enum.into(%{
        start_date: ~D[2024-04-24],
        end_date: ~D[2024-04-29],
        name: "someName #{System.unique_integer()}"
      })
      |> VotaSanremo.Editions.create_edition()

    edition
  end
end
