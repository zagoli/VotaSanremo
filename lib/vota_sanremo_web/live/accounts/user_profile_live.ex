defmodule VotaSanremoWeb.UserProfileLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.PerformersScores
  alias VotaSanremo.Accounts
  alias VotaSanremo.Editions
  alias VotaSanremo.Performers

  def mount(%{"user_id" => user_id}, _session, socket) do
    {:ok,
     socket
     |> assign_requested_user(user_id)
     |> maybe_assign_user_scores()}
  end

  defp assign_requested_user(socket, user_id) do
    user = Accounts.get_user!(user_id)
    assign(socket, :user, user)
  end

  defp maybe_assign_user_scores(
         %{assigns: %{user: %Accounts.User{votes_privacy: :private}}} = socket
       ),
       do: socket

  defp maybe_assign_user_scores(
         %{assigns: %{user: %Accounts.User{votes_privacy: :public} = user}} = socket
       ) do
    edition = Editions.get_latest_edition!()
    scores = Performers.list_performers_avg_score_by_edition_by_user(edition.id, user)
    assign(socket, :scores, scores)
  end
end
