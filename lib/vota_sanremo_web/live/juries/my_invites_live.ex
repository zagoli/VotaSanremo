defmodule VotaSanremoWeb.MyInvitesLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Juries

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_pending_invitations()}
  end

  defp assign_pending_invitations(%{assigns: %{current_user: user}} = socket) do
    assign(socket, :pending_invitations, Juries.list_user_pending_invitations(user))
  end
end
