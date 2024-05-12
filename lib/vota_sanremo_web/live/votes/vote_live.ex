defmodule VotaSanremoWeb.Votes.VoteLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.EveningSelector
  alias VotaSanremo.Editions
  alias VotaSanremo.Performances

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_evenings
     |> assign_default_selected_evening}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp assign_evenings(socket) do
    %{evenings: evenings} = Editions.get_latest_edition_with_evenings!()
    assign(socket, :evenings, evenings)
  end

  defp assign_selected_evening_with_performances(socket, evening) do
    assign(socket,
      selected_evening: evening,
      performances: Performances.list_performances_of_evening(evening, socket.assigns.current_user)
    )
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
end
