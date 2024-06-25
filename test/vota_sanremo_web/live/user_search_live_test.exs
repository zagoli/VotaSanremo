defmodule VotaSanremoWeb.UserSearchLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias VotaSanremo.AccountsFixtures

  describe "User search" do
    setup [:register_and_log_in_user]

    setup do
      first_users_group =
        for n <- 1..10 do
          AccountsFixtures.user_fixture(%{username: "user#{n}"})
        end

      second_users_group =
        for n <- 1..10 do
          AccountsFixtures.user_fixture(%{username: "happy#{n}"})
        end

      %{first_users_group: first_users_group, second_users_group: second_users_group}
    end

    test "initially renders form and no users list", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/search/users")

      assert html =~ "search-users-form"
      refute html =~ "<ul>"
    end

    test "renders only searched users", %{
      conn: conn,
      first_users_group: first_users_group,
      second_users_group: second_users_group
    } do
      {:ok, live, _html} = live(conn, ~p"/search/users")

      html =
        form(live, "#search-users-form", username: %{username: "user"})
        |> render_change()

      Enum.each(first_users_group, fn user ->
        assert html =~ user.username
      end)

      Enum.each(second_users_group, fn user ->
        refute html =~ user.username
      end)
    end

    test "renders other users after first search", %{
      conn: conn,
      second_users_group: second_users_group
    } do
      {:ok, live, _html} = live(conn, ~p"/search/users")

      form(live, "#search-users-form", username: %{username: "user"})
      |> render_change()

      html =
        form(live, "#search-users-form", username: %{username: "happy"})
        |> render_change()

      Enum.each(second_users_group, fn user ->
        assert html =~ user.username
      end)
    end
  end
end
