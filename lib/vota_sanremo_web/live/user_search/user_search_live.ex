defmodule VotaSanremoWeb.UserSearchLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.SimpleList
  alias VotaSanremo.{UserSearch, Accounts}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_form(UserSearch.change_username())
     |> assign_users()}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_users(socket, users \\ []) do
    assign(socket, :users, users)
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
