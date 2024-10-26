defmodule VotaSanremoWeb.Admin.ManageEditionsLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Editions

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_editions}
  end

  defp assign_editions(socket) do
    socket
    |> assign(:editions, Editions.list_editions_with_evenings())
  end

end
