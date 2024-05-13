defmodule VotaSanremoWeb.Votes.PerformancesContainer do
  @moduledoc """
  Provides a function component for displaying a list of performances.
  """
  use Phoenix.Component
  alias VotaSanremo.Performances.PerformanceType
  alias VotaSanremo.ScoresUtils

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
  attr :class, :string, default: nil

  def performances_container(assigns) do
    ~H"""
    <.live_component
      module={VotaSanremoWeb.Votes.PerformancesContainer.Internal}
      id={"#{@performances_type.type}-performances-container"}
      performances_type={@performances_type}
      performances={@performances}
      can_user_vote={@can_user_vote}
      class={@class}
    />
    """
  end
end

defmodule VotaSanremoWeb.Votes.PerformancesContainer.Internal do
  @moduledoc """
  Internal implementation of performances container. Do not use directly
  """
  alias VotaSanremo.ScoresUtils
  use VotaSanremoWeb, :live_component
  import VotaSanremoWeb.PresentationTable
  import VotaSanremoWeb.CoreComponents, only: [header: 1]

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
    <section class={@class}>
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
            phx-target={@myself}
          >
            <%= if Enum.empty?(performance.votes) do
              "-"
            else
              performance.votes |> List.first() |> Map.get(:score) |> ScoresUtils.to_string()
            end %>
          </.button_badge>
        </:property>
      </.presentation_table>
    </section>
    """
  end

  def handle_event(
        "vote-clicked",
        %{"value" => performance_id},
        %{assigns: %{performances: performances}} = socket
      ) do
    performance =
      performances
      |> Enum.find(fn performance -> performance.id == String.to_integer(performance_id) end)

    path =
      if Enum.empty?(performance.votes) do
        ~p"/vote/performance/new/#{performance_id}"
      else
        ~p"/vote/performance/edit/#{performance_id}"
      end

    {:noreply, push_patch(socket, to: path)}
  end
end
