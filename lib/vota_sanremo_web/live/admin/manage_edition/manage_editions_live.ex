defmodule VotaSanremoWeb.Admin.ManageEditionsLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.Admin.EditionEditor
  import VotaSanremo.GetFreshName
  alias VotaSanremo.Editions

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_editions}
  end

  defp assign_editions(socket) do
    socket
    |> assign(:editions, Editions.list_editions_with_evenings())
  end

  def handle_info({VotaSanremoWeb.Admin.EditionEditorInternal, :edition_updated}, socket) do
    {:noreply, socket |> assign_editions}
  end

  def handle_event("new_edition", _params, socket) do
    new_name = get_fresh_name(gettext("New edition"), Editions.list_editions_names())

    case Editions.create_edition(%{
           name: new_name,
           start_date: Date.utc_today(),
           end_date: Date.utc_today()
         }) do
      {:ok, _} ->
        {:noreply, assign_editions(socket)}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, gettext("Error creating the edition"))}
    end
  end
end
