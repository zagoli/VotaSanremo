defmodule VotaSanremoWeb.JuryMembersLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.SimpleList
  alias VotaSanremo.Juries
  alias VotaSanremo.Accounts

  def mount(%{"jury_id" => jury_id}, _session, socket) do
    {:ok,
     socket
     |> assign_jury(jury_id)
     |> assign_is_founder()
     |> assign_pending_invites()}
  end

  defp assign_is_founder(%{assigns: %{current_user: nil}} = socket) do
    assign(socket, :is_founder, false)
  end

  defp assign_is_founder(%{assigns: %{current_user: user, jury: jury}} = socket) do
    assign(socket, :is_founder, user.id === jury.founder)
  end

  defp assign_jury(socket, jury_id) do
    assign(socket, :jury, Juries.get_jury_with_members(jury_id))
  end

  defp assign_pending_invites(%{assigns: %{is_founder: false}} = socket) do
    socket
  end

  defp assign_pending_invites(%{assigns: %{jury: jury}} = socket) do
    assign(socket, :pending_invites, Juries.list_jury_pending_invites(jury))
  end

  def handle_params(
        %{"jury_id" => jury_id, "user_id" => user_id},
        _uri,
        socket
      ) do
    {:noreply,
     socket
     |> invite_member(String.to_integer(jury_id), String.to_integer(user_id))
     |> push_navigate(to: ~p"/juries/#{jury_id}/members")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp invite_member(%{assigns: %{current_user: %{id: current_user_id}}} = socket, _, user_id)
       when is_integer(user_id) and user_id == current_user_id do
    socket |> put_flash(:error, dgettext("juries", "You cannot invite yourself!"))
  end

  defp invite_member(%{assigns: %{current_user: user}} = socket, jury_id, user_id)
       when is_integer(jury_id) and is_integer(user_id) do
    jury = Juries.get_jury!(jury_id)

    if jury.founder !== user.id do
      socket |> put_flash(:error, dgettext("juries", "You are not allowed to invite a user!"))
    else
      case Juries.create_jury_invite(%{status: :pending, jury_id: jury_id, user_id: user_id}) do
        {:ok, invite} ->
          recipient = Accounts.get_user!(user_id)

          Juries.deliver_user_invite(recipient, %{
            jury_name: jury.name,
            accept_url: url(~p"/juries/my_invites/accept/#{invite.id}"),
            decline_url: url(~p"/juries/my_invites/decline/#{invite.id}"),
            my_invites_url: url(~p"/juries/my_invites")
          })

          socket |> put_flash(:info, dgettext("juries", "User invited"))

        {:error, _} ->
          socket |> put_flash(:error, dgettext("juries", "Error inviting user"))
      end
    end
  end

  def handle_event("remove-member", %{"value" => member_id}, %{assigns: %{jury: jury}} = socket) do
    member = jury.members |> Enum.find(&(&1.id === String.to_integer(member_id)))

    case Juries.member_exit(jury, member) do
      :ok ->
        {:noreply,
         socket |> assign_jury(jury.id) |> put_flash(:info, dgettext("juries", "Member removed!"))}

      :error ->
        {:noreply, socket |> put_flash(:error, dgettext("juries", "Error removing member."))}
    end
  end
end
