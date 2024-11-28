defmodule VotaSanremoWeb.JuryMembersLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Juries

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"jury_id" => jury_id, "user_id" => user_id}, _uri, socket) do
    {:noreply,
     socket
     |> invite_member(String.to_integer(jury_id), String.to_integer(user_id))
     |> push_navigate(to: ~p"/juries/#{jury_id}/members")}
  end

  def handle_params(%{"jury_id" => jury_id}, _uri, socket) do
    {:noreply,
     socket
     |> assign_jury(jury_id)}
  end

  defp invite_member(%{assigns: %{current_user: user}} = socket, jury_id, user_id)
       when is_integer(jury_id) and is_integer(user_id) do
    jury = Juries.get_jury!(jury_id)

    if jury.founder !== user.id do
      socket |> put_flash(:error, "You are not allowed to invite a user!")
    else
      case Juries.create_jury_invitation(%{status: :pending, jury_id: jury_id, user_id: user_id}) do
        {:ok, _} -> socket |> put_flash(:info, "User invited")
        {:error, _} -> socket |> put_flash(:error, "Error inviting user")
      end
    end
  end

  defp assign_jury(socket, jury_id) do
    assign(socket, :jury, Juries.get_jury(jury_id))
  end
end
