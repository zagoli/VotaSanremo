defmodule VotaSanremoWeb.JuryLive do
  use VotaSanremoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

end
