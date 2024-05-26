defmodule VotaSanremoWeb.Votes.VoteLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.EveningSelector
  import VotaSanremoWeb.Votes.{PerformancesContainer, VoteForm}
  alias VotaSanremo.Editions
  alias VotaSanremo.Performances

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_evenings
     |> assign_default_selected_evening}
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

  defp assign_selected_evening_with_performances(socket, evening) do
    socket
    |> assign(:selected_evening, evening)
    |> assign_can_user_vote()
    |> assign_performances()
  end

  defp assign_can_user_vote(%{assigns: %{selected_evening: evening}} = socket) do
    can_user_vote =
      DateTime.after?(DateTime.utc_now(), evening.votes_start) and
        DateTime.before?(DateTime.utc_now(), evening.votes_end)

    assign(socket, :can_user_vote, can_user_vote)
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

    assign_selected_evening_with_performances(socket, default_evening)
  end

  def handle_event("evening-selected", %{"value" => evening_id}, socket) do
    evening =
      Enum.find(socket.assigns.evenings, List.first(socket.assigns.evenings), fn evening ->
        evening.id == String.to_integer(evening_id)
      end)

    {:noreply,
     socket
     |> assign_selected_evening_with_performances(evening)}
  end

  def handle_info({VotaSanremoWeb.Votes.VoteFormInternal, {:saved, performance_id, vote}}, socket) do
    {:noreply,
     socket
     |> update(:performances, fn performances ->
       performance_index = Enum.find_index(performances, &(&1.id == performance_id))
       List.update_at(performances, performance_index, &Map.put(&1, :votes, [vote]))
     end)}
  end

  defp group_performances(performances) do
    Enum.group_by(performances, & &1.performance_type)
    |> Enum.map(fn {performance_type, performance} -> {performance_type.type, performance} end)
    # order group types
    |> Enum.sort(&(elem(&1, 0) >= elem(&2, 0)))
  end
end
