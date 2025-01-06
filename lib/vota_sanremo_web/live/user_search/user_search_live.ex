defmodule VotaSanremoWeb.UserSearchLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.SimpleList
  alias VotaSanremo.{UserSearch, Accounts}

  def mount(_params, _session, socket) do
    initial_users = Accounts.list_some_users(20)

    {:ok,
     socket
     |> assign_form(UserSearch.change_username())
     |> assign_users(initial_users)}
  end

  def handle_params(%{"jury_id" => jury_id}, _uri, socket) do
    {:noreply, assign(socket, :jury_id, jury_id)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_users(%{assigns: %{current_user: user}} = socket, users) do
    # Current user should not be included in the searched users
    assign(socket, :users, List.delete(users, user))
  end

  def handle_event("search", %{"username" => params}, socket) do
    changeset =
      UserSearch.change_username(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign_form(changeset)
     |> search(changeset)}
  end

  defp search(socket, %{valid?: false} = _changeset) do
    socket
  end

  defp search(socket, %{valid?: true} = changeset) do
    users = Accounts.list_users_by_username(changeset)
    assign_users(socket, users)
  end
end
