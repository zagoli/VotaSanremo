defmodule VotaSanremoWeb.Admin.ManageEditionsLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.Admin.EditionEditor
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

end
