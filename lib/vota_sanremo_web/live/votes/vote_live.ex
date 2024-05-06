defmodule VotaSanremoWeb.Votes.VoteLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.EveningSelector
  alias VotaSanremo.Editions

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_evenings
     |> assign_default_selected_evening}
  end

  defp assign_evenings(socket) do
    %{evenings: evenings} = Editions.get_latest_edition_with_evenings!()
    assign(socket, :evenings, evenings)
  end

  defp assign_selected_evening(socket, evening) do
    assign(socket, :selected_evening, evening)
  end

  defp assign_default_selected_evening(socket) do
    first_evening =
      socket.assigns.evenings
      |> Enum.sort(&(&1.date < &2.date))
      |> List.first()

    assign_selected_evening(socket, first_evening)
  end

  def handle_event("evening-selected", %{"value" => evening_id}, socket) do
    evening =
      Enum.find(socket.assigns.evenings, List.first(socket.assigns.evenings), fn evening ->
        evening.id == String.to_integer(evening_id)
      end)

    {:noreply,
     socket
     |> assign_selected_evening(evening)}
  end
end
