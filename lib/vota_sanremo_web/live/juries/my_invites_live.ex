defmodule VotaSanremoWeb.MyInvitesLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Juries

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_pending_invitations()}
  end

  defp assign_pending_invitations(%{assigns: %{current_user: user}} = socket) do
    assign(socket, :pending_invitations, Juries.list_user_pending_invitations(user))
  end

  def handle_event(
        "accept",
        %{"value" => jury_invitation_id},
        %{assigns: %{pending_invitations: invitations}} = socket
      ) do
    jury_invitation = Enum.find(invitations, &(&1.id == String.to_integer(jury_invitation_id)))

    case Juries.accept_invitation(jury_invitation) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invite accepted! You are now part of #{jury_invitation.jury.name}")
         |> assign_pending_invitations()}

      {:error, _} ->
        socket |> put_flash(:error, "Error while accepting this invite. Sorry!")
    end
  end
end
