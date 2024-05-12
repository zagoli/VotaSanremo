defmodule VotaSanremoWeb.Votes.PerformancesContainer do
  @moduledoc """
  Provides a function component for displaying a list of performances.
  """
  use Phoenix.Component
  import VotaSanremoWeb.PresentationTable
  import VotaSanremoWeb.CoreComponents, only: [header: 1]
  alias VotaSanremo.Performances.PerformanceType


  @doc """
  A container used to show a list of performances with a header of performances type.
  For each performance is rendered a row in the list, with the performance name and a button.
  The button shows the performance vote, and if there is none, an hyphen.
  When the button is clicked a vote-clicked event is generated, with the value of the clicked performance id.

  ## Examples

      <.performances_container
        performances_type={type}
        performances={performances}
        can_user_vote={true}/>
  """
  attr :performances_type, PerformanceType, required: true
  attr :performances, :list, required: true
  attr :can_user_vote, :boolean, required: true

  def performances_container(assigns) do
    ~H"""
    <.header class="mb-2">
      <%= @performances_type.type %>
    </.header>

    <.presentation_table items={@performances}>
      <:name :let={performance}>
        <p class="font-bold text-xl">
          <%= performance.performer.name %>
        </p>
      </:name>

      <:property :let={performance}>
        <.button_badge
          disabled={not @can_user_vote}
          phx-click="vote-clicked"
          value={performance.id}
        >
          <%= if Enum.empty?(performance.votes) do
            "-"
          else
            performance.votes |> List.first() |> Map.get(:score)
          end %>
        </.button_badge>
      </:property>
    </.presentation_table>
    """
  end
end
