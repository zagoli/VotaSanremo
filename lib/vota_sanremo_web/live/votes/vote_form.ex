defmodule VotaSanremoWeb.VoteForm do
  @moduledoc """
  Provides a form for voting a performance.
  """
  use Phoenix.Component
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Performances.Performance
  alias VotaSanremo.Evenings.Evening

  attr :performance, Performance, required: true
  attr :user, User, required: true
  attr :evening, Evening, required: true

  def vote_form(assigns) do
    ~H"""
    <.live_component
      module={VotaSanremoWeb.VoteFormInternal}
      id="vote-form"
      performance={@performance}
      user={@user}
      evening={@evening}
    />
    """
  end
end

defmodule VotaSanremoWeb.VoteFormInternal do
  @moduledoc """
  Internal implementation of vote form. Do not use directly
  """
  use VotaSanremoWeb, :live_component
  alias VotaSanremo.Votes
  alias VotaSanremo.Votes.Vote
  alias VotaSanremo.ScoresUtils
  alias VotaSanremoWeb.Endpoint

  @votes_topic "votes"

  def update(assigns, socket) do
    changeset =
      assigns.performance
      |> get_vote()
      |> Votes.change_vote()

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign_scores()}
  end

  defp get_vote(%{votes: [vote]}), do: vote
  defp get_vote(%{votes: []}), do: %Vote{}

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_scores(socket) do
    scores =
      ScoresUtils.acceptable_scores()
      |> Enum.map(&{ScoresUtils.to_string(&1), &1})

    assign(socket, :scores, scores)
  end

  def handle_event("delete-vote", _params, %{assigns: %{evening: evening}} = socket) do
    can_user_vote =
      DateTime.after?(DateTime.utc_now(), evening.votes_start) and
        DateTime.before?(DateTime.utc_now(), evening.votes_end)

    maybe_delete_vote(socket, can_user_vote)
  end

  def handle_event(
        "score-selected",
        %{"score" => score},
        %{assigns: %{evening: evening}} = socket
      ) do
    can_user_vote =
      DateTime.after?(DateTime.utc_now(), evening.votes_start) and
        DateTime.before?(DateTime.utc_now(), evening.votes_end)

    vote_params = vote_params(socket, score)

    maybe_save_vote(socket, vote_params, can_user_vote)
  end

  defp vote_params(socket, score) do
    %{
      score: score,
      multiplier: socket.assigns.user.default_vote_multiplier,
      user_id: socket.assigns.user.id,
      performance_id: socket.assigns.performance.id
    }
  end

  defp maybe_save_vote(socket, _vote_params, false) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("You cannot vote now."))
     |> push_patch(to: ~p"/vote")}
  end

  defp maybe_save_vote(socket, vote_params, true) do
    case Votes.create_or_update_vote(vote_params) do
      {:ok, vote} ->
        notify_parent({:saved, socket.assigns.performance.id, vote})
        broadcast_vote_changed()

        {:noreply,
         socket
         |> push_patch(to: ~p"/vote")}

      {:error, %Ecto.Changeset{}} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("There was an error while submitting your vote."))
         |> push_patch(to: ~p"/vote")}
    end
  end

  defp maybe_delete_vote(socket, false) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("You cannot vote now."))
     |> push_patch(to: ~p"/vote")}
  end

  defp maybe_delete_vote(%{assigns: %{performance: performance, user: user}} = socket, true) do
    case Votes.delete_vote(performance.id, user.id) do
      :ok ->
        notify_parent({:deleted, performance.id})
        broadcast_vote_changed()

        {:noreply,
         socket
         |> push_patch(to: ~p"/vote")}

      :error ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("There was an error while deleting your vote."))
         |> push_patch(to: ~p"/vote")}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
  defp broadcast_vote_changed(), do: Endpoint.broadcast(@votes_topic, "vote_changed", :ok)
end
