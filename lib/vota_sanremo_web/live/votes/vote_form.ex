defmodule VotaSanremoWeb.Votes.VoteForm do
  @moduledoc """
  Provides a form for voting a performance.
  """
  use Phoenix.Component
  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Performances.Performance

  attr :performance, Performance, required: true
  attr :user, User, required: true
  attr :action, :atom, required: true
  attr :can_user_vote, :boolean, required: true

  def vote_form(assigns) do
    ~H"""
    <.live_component
      module={VotaSanremoWeb.Votes.VoteFormInternal}
      id="vote-form"
      performance={@performance}
      user={@user}
      action={@action}
      can_user_vote={@can_user_vote}
    />
    """
  end
end

defmodule VotaSanremoWeb.Votes.VoteFormInternal do
  @moduledoc """
  Internal implementation of vote form. Do not use directly
  """
  use VotaSanremoWeb, :live_component
  alias VotaSanremo.Votes
  alias VotaSanremo.Votes.Vote
  alias VotaSanremo.ScoresUtils

  def update(assigns, socket) do
    changeset =
      assigns.performance
      |> get_vote()
      |> Votes.change_vote()

    {:ok,
     socket
     |> assign(assigns)
     |> assign_vote()
     |> assign_form(changeset)
     |> assign_scores()}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_scores(socket) do
    scores =
      ScoresUtils.acceptable_scores()
      |> Enum.map(&{ScoresUtils.to_string(&1), &1})

    assign(socket, :scores, scores)
  end

  defp assign_vote(socket) do
    assign(socket, :vote, get_vote(socket.assigns.performance))
  end

  defp get_vote(%{votes: [vote]}), do: vote
  defp get_vote(%{votes: []}), do: %Vote{}

  def handle_event(
        "score-selected",
        _params,
        %{assigns: %{can_user_vote: false}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "You can't vote, the voting for tonight is closed.")
     |> push_patch(to: ~p"/vote")}
  end

  def handle_event(
        "score-selected",
        %{"score" => score},
        %{assigns: %{can_user_vote: true}} = socket
      ) do
    vote_params = vote_params(socket, score)
    save_vote(socket, socket.assigns.action, vote_params)
  end

  defp vote_params(socket, score) do
    %{
      score: score,
      multiplier: socket.assigns.user.default_vote_multiplier,
      user_id: socket.assigns.user.id,
      performance_id: socket.assigns.performance.id
    }
  end

  defp save_vote(socket, :new, vote_params) do
    handle_save(socket, Votes.create_vote(vote_params))
  end

  defp save_vote(socket, :edit, vote_params) do
    handle_save(socket, Votes.update_vote(socket.assigns.vote, vote_params))
  end

  defp handle_save(socket, result) do
    case result do
      {:ok, vote} ->
        notify_parent({:saved, socket.assigns.performance.id, vote})

        {:noreply,
         socket
         |> put_flash(:info, "Vote submitted!")
         |> push_patch(to: ~p"/vote")}

      {:error, %Ecto.Changeset{}} ->
        {:noreply, socket
        |> put_flash(:error, "There was an error while submitting your vote.")
        |> push_patch(to: ~p"/vote")}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
