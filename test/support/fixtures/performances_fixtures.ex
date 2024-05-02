defmodule VotaSanremo.PerformancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Performances` context.
  """

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
end
