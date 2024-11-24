defmodule VotaSanremoWeb.Admin.ManagePerformersLive do
  use VotaSanremoWeb, :live_view

  alias VotaSanremo.Performers
  alias VotaSanremo.Performers.Performer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :performers, Performers.list_performers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Performer")
    |> assign(:performer, Performers.get_performer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Performer")
    |> assign(:performer, %Performer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Performers")
    |> assign(:performer, nil)
  end

  @impl true
  def handle_info({VotaSanremoWeb.PerformerLive.FormComponent, {:saved, performer}}, socket) do
    {:noreply, stream_insert(socket, :performers, performer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    performer = Performers.get_performer!(id)
    {:ok, _} = Performers.delete_performer(performer)

    {:noreply, stream_delete(socket, :performers, performer)}
  end
end
