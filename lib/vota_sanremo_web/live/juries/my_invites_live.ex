defmodule VotaSanremoWeb.MyInvitesLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Juries

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_pending_invites()}
  end

  defp assign_pending_invites(%{assigns: %{current_user: user}} = socket) do
    assign(socket, :pending_invites, Juries.list_user_pending_invites(user))
  end

  def handle_event(
        "accept",
        %{"value" => jury_invite_id},
        %{assigns: %{pending_invites: invites}} = socket
      ) do
    jury_invite = invite_from_string_id(invites, jury_invite_id)

    case Juries.accept_invite(jury_invite) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invite accepted! You are now part of #{jury_invite.jury.name}")
         |> assign_pending_invites()}

      {:error, _} ->
        socket |> put_flash(:error, "Error while accepting this invite. Sorry!")
    end
  end

  def handle_event(
        "decline",
        %{"value" => jury_invite_id},
        %{assigns: %{pending_invites: invites}} = socket
      ) do
    jury_invite = invite_from_string_id(invites, jury_invite_id)

    case Juries.decline_invite(jury_invite) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invite declined.")
         |> assign_pending_invites()}

      {:error, _} ->
        socket |> put_flash(:error, "Error while declining this invite. Sorry!")
    end
  end

  defp invite_from_string_id(invites, invite_id)
       when is_binary(invite_id) and is_list(invites) do
    Enum.find(invites, &(&1.id == String.to_integer(invite_id)))
  end
end
