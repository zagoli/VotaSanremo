defmodule VotaSanremoWeb.Leaderboard.LeaderboardLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.PresentationTable
  alias VotaSanremo.{Editions, Performers}
  alias VotaSanremoWeb.Endpoint

  @votes_topic "votes"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@votes_topic)
    end

    {:ok,
     socket
     |> assign_edition
     |> assign_weighted_flag(false)
     |> assign_scores()}
  end

  defp assign_edition(socket) do
    assign(socket, :edition, Editions.get_latest_edition!())
  end

  defp assign_weighted_flag(socket, flag) do
    assign(socket, :weighted?, flag)
  end

  defp assign_scores(%{assigns: %{weighted?: false, edition: edition}} = socket) do
    assign(socket, :scores, Performers.list_performers_avg_score_by_edition(edition.id))
  end

  defp assign_scores(%{assigns: %{weighted?: true, edition: edition}} = socket) do
    assign(socket, :scores, Performers.list_performers_weighted_avg_score_by_edition(edition.id))
  end

  defp order_and_group_scores(scores) do
    scores
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.group_by(& &1.performance_type)
    # order group types
    |> Enum.sort(&(elem(&1, 0) >= elem(&2, 0)))
  end

  def handle_event("weighted-flag-selected", %{"weighted-scores-flag" => flag}, socket) do
    {:noreply,
     socket
     |> assign_weighted_flag(flag == "true")
     |> assign_scores()}
  end

  def handle_info(%{event: "vote_added", payload: :ok}, socket) do
    {:noreply, assign_scores(socket)}
  end
end
