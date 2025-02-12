defmodule VotaSanremoWeb.Admin.ManagePerformanceTypesLive do
  use VotaSanremoWeb, :live_view

  alias VotaSanremo.Performances
  alias VotaSanremo.Performances.PerformanceType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :performance_types, Performances.list_performance_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("performances", "Edit performance type"))
    |> assign(:performance_type, Performances.get_performance_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("performances", "New performance type"))
    |> assign(:performance_type, %PerformanceType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("performances", "Performance types"))
    |> assign(:performance_type, nil)
  end

  @impl true
  def handle_info(
        {VotaSanremoWeb.PerformanceTypeLive.FormComponent, {:saved, performance_type}},
        socket
      ) do
    {:noreply, stream_insert(socket, :performance_types, performance_type)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    performance_type = Performances.get_performance_type!(id)
    {:ok, _} = Performances.delete_performance_type(performance_type)

    {:noreply, stream_delete(socket, :performance_types, performance_type)}
  end
end
