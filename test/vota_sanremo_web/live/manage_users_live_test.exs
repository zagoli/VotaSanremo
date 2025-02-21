defmodule VotaSanremoWeb.ManageUsersLiveTest do
  use VotaSanremoWeb.ConnCase

  import Phoenix.LiveViewTest
  import VotaSanremo.AccountsFixtures

  @users_number 5
  @confirmed_users_number 3

  defp create_users(_) do
    users =
      for _ <- 1..@users_number do
        user_fixture()
      end

    users |> Enum.take(@confirmed_users_number) |> Enum.each(&confirm_user/1)

    %{users: users}
  end

  describe "Manage users" do
    setup [:register_and_log_in_admin, :create_users]

    test "it is possible to view the number of registered users with role user", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/admin/users")

      assert html =~ "Number of registered users"
      assert Floki.find(html, "#users-number") |> Floki.text() =~ Integer.to_string(@users_number)

      assert html =~ "Number of confirmed users"

      assert Floki.find(html, "#confirmed-users-number") |> Floki.text() =~
               Integer.to_string(@confirmed_users_number)
    end
  end
end
