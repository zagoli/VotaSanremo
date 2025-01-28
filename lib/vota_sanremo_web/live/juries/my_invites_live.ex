defmodule VotaSanremoWeb.MyInvitesLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Juries

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_pending_invites()}
  end

  defp assign_pending_invites(%{assigns: %{current_user: user}} = socket) do
    assign(socket, :pending_invites, Juries.list_user_pending_invites(user))
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _), do: socket

  defp apply_action(socket, :accept, %{"jury_invite_id" => jury_invite_id}) do
    jury_invite = invite_from_string_id(socket.assigns.pending_invites, jury_invite_id)

    case Juries.accept_invite(jury_invite) do
      {:ok, _} ->
        socket
        |> put_flash(
          :info,
          gettext("Invite accepted! You are now part of %{jury_name}",
            jury_name: jury_invite.jury.name
          )
        )
        |> assign_pending_invites()

      {:error, _} ->
        socket |> put_flash(:error, gettext("Error while accepting this invite. Sorry!"))

      nil ->
        socket |> put_flash(:error, gettext("Error while accepting this invite. Sorry!"))
    end
  end

  defp apply_action(socket, :decline, %{"jury_invite_id" => jury_invite_id}) do
    jury_invite = invite_from_string_id(socket.assigns.pending_invites, jury_invite_id)

    case Juries.decline_invite(jury_invite) do
      {:ok, _} ->
        socket
        |> put_flash(:info, gettext("Invite declined."))
        |> assign_pending_invites()

      {:error, _} ->
        socket |> put_flash(:error, gettext("Error while declining this invite. Sorry!"))

      nil ->
        socket |> put_flash(:error, gettext("Error while accepting this invite. Sorry!"))
    end
  end

  defp invite_from_string_id(invites, invite_id)
       when is_binary(invite_id) and is_list(invites) do
    Enum.find(invites, &(&1.id == String.to_integer(invite_id)))
  end
end
