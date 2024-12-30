defmodule VotaSanremoWeb.JuryLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.PerformersScores
  alias VotaSanremo.Juries
  alias VotaSanremo.Editions
  alias VotaSanremo.Performers
  alias VotaSanremo.Accounts

  def mount(%{"jury_id" => jury_id}, _session, socket) do
    {:ok,
     socket
     |> assign_edition()
     |> assign_jury(jury_id)
     |> assign_founder()
     |> assign_weighted_flag(false)
     |> assign_scores()
     |> assign_is_member()}
  end

  defp assign_jury(socket, jury_id) do
    assign(socket, :jury, Juries.get_jury(jury_id))
  end

  defp assign_founder(socket) do
    assign(socket, :founder, Accounts.get_user!(socket.assigns.jury.founder))
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

  defp assign_is_member(%{assigns: %{current_user: nil}} = socket) do
    assign(socket, :is_member, false)
  end

  defp assign_is_member(%{assigns: %{current_user: user, jury: jury}} = socket) do
    assign(socket, :is_member, Juries.member?(jury, user))
  end

  def handle_event("weighted-flag-selected", %{"weighted-scores-flag" => flag}, socket) do
    {:noreply,
     socket
     |> assign_weighted_flag(flag == "true")
     |> assign_scores()}
  end

  def handle_event("exit-jury", _params, socket) do
    case Juries.member_exit(socket.assigns.jury, socket.assigns.current_user) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("You have successfully exited the jury!"))
         |> push_navigate(to: ~p"/juries")}

      :error ->
        {:noreply, socket |> put_flash(:error, gettext("Error exiting the jury"))}
    end
  end
end
