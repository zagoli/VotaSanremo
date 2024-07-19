defmodule VotaSanremoWeb.JuryLive do
  use VotaSanremoWeb, :live_view

  alias VotaSanremo.Juries

  def mount(%{"jury_id" => jury_id}, _session, socket) do
    {:ok,
     socket
     |> assign_jury(jury_id)}
  end

  defp assign_jury(socket, jury_id) do
    assign(socket, :jury, Juries.get_jury(jury_id))
  end
end
