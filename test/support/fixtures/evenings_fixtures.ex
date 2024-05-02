defmodule VotaSanremo.EveningsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Evenings` context.
  """
  alias VotaSanremo.EditionsFixtures

  @doc """
  Generate a evening.
  """
  def evening_fixture(attrs \\ %{}) do
    edition = EditionsFixtures.edition_fixture()
    {:ok, evening} =
      attrs
      |> Enum.into(%{
        date: random_date(),
        description: "some description",
        number: 42,
        votes_end: ~U[2024-04-29 14:47:00Z],
        votes_start: ~U[2024-04-29 14:47:00Z],
        edition_id: edition.id
      })
      |> VotaSanremo.Evenings.create_evening()

    evening
  end

  def random_date() do
    year = Enum.random(1970..2035)
    month = Enum.random(1..12)
    day = Enum.random(1..28)
    Date.new!(year, month, day)
  end
end
