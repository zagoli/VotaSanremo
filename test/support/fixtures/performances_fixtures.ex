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
    {:ok, performance} =
      attrs
      |> Enum.into(%{
        performance_type_id:
          if not Map.has_key?(attrs, :performance_type_id) do
            %{id: id} = performance_type_fixture()
            id
          end,
        performer_id:
          if not Map.has_key?(attrs, :performer_id) do
            %{id: id} = PerformersFixtures.performer_fixture()
            id
          end,
        evening_id:
          if not Map.has_key?(attrs, :evening_id) do
            %{id: id} = EveningsFixtures.evening_fixture()
            id
          end
      })
      |> VotaSanremo.Performances.create_performance()

    performance
  end
end
