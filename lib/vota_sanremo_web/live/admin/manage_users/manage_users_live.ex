defmodule VotaSanremoWeb.Admin.ManageUsersLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Accounts

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign_users_number()
     |> assign_confirmed_users_number()}
  end

  defp assign_users_number(socket) do
    assign(socket, :users_number, Accounts.count_users())
  end

  defp assign_confirmed_users_number(socket) do
    assign(socket, :confirmed_users_number, Accounts.count_confirmed_users())
  end
end
