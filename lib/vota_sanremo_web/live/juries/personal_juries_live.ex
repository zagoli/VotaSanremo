defmodule VotaSanremoWeb.PersonalJuriesLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Juries

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_member_juries()}
  end

  defp assign_member_juries(%{assigns: %{current_user: user}} = socket) do
    juries = Juries.list_member_juries(user)
    assign(socket, :member_juries, juries)
  end
end
