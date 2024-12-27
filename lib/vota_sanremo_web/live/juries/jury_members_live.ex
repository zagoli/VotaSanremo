defmodule VotaSanremoWeb.JuryMembersLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.SimpleList
  alias VotaSanremo.Juries

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

  def handle_params(%{"jury_id" => jury_id, "user_id" => user_id}, _uri, socket) do
    {:noreply,
     socket
     |> invite_member(String.to_integer(jury_id), String.to_integer(user_id))
     |> push_navigate(to: ~p"/juries/#{jury_id}/members")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp invite_member(%{assigns: %{current_user: user}} = socket, jury_id, user_id)
       when is_integer(jury_id) and is_integer(user_id) do
    jury = Juries.get_jury!(jury_id)

    if jury.founder !== user.id do
      socket |> put_flash(:error, gettext("You are not allowed to invite a user!"))
    else
      case Juries.create_jury_invite(%{status: :pending, jury_id: jury_id, user_id: user_id}) do
        {:ok, _} -> socket |> put_flash(:info, gettext("User invited"))
        {:error, _} -> socket |> put_flash(:error, gettext("Error inviting user"))
      end
    end
  end
end
