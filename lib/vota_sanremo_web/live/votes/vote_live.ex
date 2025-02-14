defmodule VotaSanremoWeb.VoteLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.EveningSelector
  import VotaSanremoWeb.{PerformancesContainer, VoteForm}
  alias VotaSanremo.Editions
  alias VotaSanremo.Performances
  alias VotaSanremo.Evenings

  @update_voting_msg :update_voting_status

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_evenings()
     |> assign_default_selected_evening()
     |> assign(:timer, nil)}
  end

  def handle_params(
        %{"id" => performance_id},
        _uri,
        %{assigns: %{performances: performances}} = socket
      ) do
    performance = Enum.find(performances, &(&1.id == String.to_integer(performance_id)))

    {:noreply,
     if performance == nil do
       push_navigate(socket, to: ~p"/vote")
     else
       assign(socket, :performance, performance)
     end}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp assign_evenings(socket) do
    %{evenings: evenings} = Editions.get_latest_edition_with_evenings!()
    assign(socket, :evenings, evenings)
  end

  defp assign_evening_with_performances(socket, evening) do
    socket
    |> assign(:selected_evening, evening)
    |> assign_voting_status()
    |> assign_can_user_vote()
    |> assign_timer()
    |> assign_performances()
  end

  defp assign_voting_status(%{assigns: %{selected_evening: evening}} = socket) do
    assign(socket, :voting_status, Evenings.get_voting_status(evening))
  end

  defp assign_can_user_vote(%{assigns: %{voting_status: voting_status}} = socket) do
    assign(socket, :can_user_vote, voting_status == :open)
  end

  defp assign_performances(
         %{assigns: %{selected_evening: evening, current_user: current_user}} = socket
       ) do
    performances = Performances.list_performances_of_evening(evening, current_user)
    assign(socket, :performances, performances)
  end

  defp assign_default_selected_evening(%{assigns: %{evenings: evenings}} = socket) do
    first_evening =
      evenings
      |> Enum.sort(&(&1.date < &2.date))
      |> List.first()

    today = DateTime.utc_now() |> DateTime.to_date()
    default_evening = Enum.find(evenings, first_evening, fn e -> e.date == today end)

    assign_evening_with_performances(socket, default_evening)
  end

  # ----------- SET TIMER -------------------------------------------------------------------------------------------

  # If the timer is already set, cancel it and set a new one
  defp assign_timer(%{assigns: %{timer: t}} = socket) when is_reference(t) do
    Process.cancel_timer(t)

    assign(socket, :timer, nil)
    |> assign_timer()
  end

  # Set a timer to open the voting when it expires
  defp assign_timer(%{assigns: %{voting_status: :before, selected_evening: evening}} = socket) do
    time = DateTime.diff(evening.votes_start, DateTime.utc_now(), :millisecond)
    set_timer(socket, time)
  end

  # Set a timer to close the voting when it expires
  defp assign_timer(%{assigns: %{voting_status: :open, selected_evening: evening}} = socket) do
    time = DateTime.diff(evening.votes_end, DateTime.utc_now(), :millisecond)
    set_timer(socket, time)
  end

  # Do not set a timer if the voting is already closed
  defp assign_timer(%{assigns: %{voting_status: :after}} = socket) do
    socket
  end

  # Sends @update_voting_msg to the current process after a given time
  defp set_timer(socket, time) do
    timer = Process.send_after(self(), @update_voting_msg, time)
    assign(socket, :timer, timer)
  end

  # ----------- HANDLE EVENING SELECTED ------------------------------------------------------------------------------

  def handle_event("evening-selected", %{"value" => evening_id}, socket) do
    evening =
      Enum.find(socket.assigns.evenings, List.first(socket.assigns.evenings), fn evening ->
        evening.id == String.to_integer(evening_id)
      end)

    {:noreply,
     socket
     |> assign_evening_with_performances(evening)}
  end

  # ----------- HANDLE VOTE FORM MESSAGES ----------------------------------------------------------------------------

  def handle_info({VotaSanremoWeb.VoteFormInternal, {:saved, performance_id, vote}}, socket) do
    {:noreply,
     socket
     |> update(:performances, fn performances ->
       performance_index = Enum.find_index(performances, &(&1.id == performance_id))
       List.update_at(performances, performance_index, &Map.put(&1, :votes, [vote]))
     end)}
  end

  def handle_info({VotaSanremoWeb.VoteFormInternal, {:deleted, performance_id}}, socket) do
    {:noreply,
     socket
     |> update(:performances, fn performances ->
       performance_index = Enum.find_index(performances, &(&1.id == performance_id))
       List.update_at(performances, performance_index, &Map.put(&1, :votes, []))
     end)}
  end

  # ----------- HANDLE TIMER MESSAGES ---------------------------------------------------------------------------------

  def handle_info(@update_voting_msg, socket) do
    {:noreply,
     socket
     |> assign(:timer, nil)
     |> assign_voting_status()
     |> assign_can_user_vote()
     |> assign_timer()}
  end

  defp group_performances(performances) do
    Enum.group_by(performances, & &1.performance_type)
    |> Enum.map(fn {performance_type, performance} -> {performance_type.type, performance} end)
    # order group types
    |> Enum.sort(&(elem(&1, 0) >= elem(&2, 0)))
  end
end
