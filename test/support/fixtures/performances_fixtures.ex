defmodule VotaSanremo.PerformancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Performances` context.
  """
  alias VotaSanremo.{EveningsFixtures, PerformersFixtures}

  @doc """
  Generate a unique performance_type type.
  """
  def unique_performance_type_type, do: "some type#{System.unique_integer([:positive])}"

  @doc """
  Generate a performance_type.
  """
  def performance_type_fixture(attrs \\ %{}) do
    {:ok, performance_type} =
      attrs
      |> Enum.into(%{
        type: unique_performance_type_type()
      })
      |> VotaSanremo.Performances.create_performance_type()

    performance_type
  end

  @doc """
  Generate a performance.
  """
  def performance_fixture(attrs \\ %{}) do
    type = performance_type_fixture()
    performer = PerformersFixtures.performer_fixture()
    evening = EveningsFixtures.evening_fixture()

    {:ok, performance} =
      attrs
      |> Enum.into(%{
        performance_type_id: type.id,
        performer_id: performer.id,
        evening_id: evening.id
      })
      |> VotaSanremo.Performances.create_performance()

    performance
  end
end
