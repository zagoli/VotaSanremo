defmodule VotaSanremoWeb.JuryLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.PerformersScores
  alias VotaSanremo.Juries
  alias VotaSanremo.Editions
  alias VotaSanremo.Performers

  def mount(%{"jury_id" => jury_id}, _session, socket) do
    {:ok,
     socket
     |> assign_jury(jury_id)
     |> assign_edition()
     |> assign_weighted_flag(false)
     |> assign_scores()}
  end

  defp assign_jury(socket, jury_id) do
    assign(socket, :jury, Juries.get_jury(jury_id))
  end

  defp assign_edition(socket) do
    assign(socket, :edition, Editions.get_latest_edition!())
  end

  defp assign_weighted_flag(socket, flag) do
    assign(socket, :weighted?, flag)
  end

  defp assign_scores(%{assigns: %{weighted?: false, edition: edition, jury: jury}} = socket) do
    assign(
      socket,
      :scores,
      Performers.list_performers_avg_score_by_edition_by_jury(edition.id, jury)
    )
  end

  defp assign_scores(%{assigns: %{weighted?: true, edition: edition, jury: jury}} = socket) do
    assign(
      socket,
      :scores,
      Performers.list_performers_weighted_score_by_edition_by_jury(edition.id, jury)
    )
  end

  def handle_event("weighted-flag-selected", %{"weighted-scores-flag" => flag}, socket) do
    {:noreply,
     socket
     |> assign_weighted_flag(flag == "true")
     |> assign_scores()}
  end
end
