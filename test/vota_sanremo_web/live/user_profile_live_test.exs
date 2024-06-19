defmodule VotaSanremoWeb.UserProfileLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias VotaSanremo.TestSetupFixtures

  defp create_votes(%{user: user}) do
    {_, performer, first_performance_type, second_performance_type} =
      TestSetupFixtures.setup_for_avg_score_by_user_test(user)

    %{
      performer: performer,
      first_performance_type: first_performance_type,
      second_performance_type: second_performance_type
    }
  end

  describe "User profile page" do
    alias VotaSanremo.Accounts

    setup [:register_and_log_in_user, :create_votes]

    test "renders user votes", %{
      conn: conn,
      user: user,
      performer: performer,
      first_performance_type: first_performance_type,
      second_performance_type: second_performance_type
    } do
      {:ok, _live, html} = live(conn, ~p"/users/profile/#{user.id}")

      assert html =~ "Votes"
      assert html =~ performer
      assert html =~ first_performance_type
      assert html =~ second_performance_type
      assert html =~ "5.0"
      refute html =~ "1.0"
    end

    test "does not render user votes when they are private", %{conn: conn, user: user} do
      # TODO: use correct functions to update the user when implemented
      {:ok, _} =
        user
        |> Accounts.change_user_registration(%{
          votes_privacy: :private,
          password: "FakePassword99"
        })
        |> VotaSanremo.Repo.update()

      {:ok, _live, html} = live(conn, ~p"/users/profile/#{user.id}")

      assert html =~ "Votes"
      assert html =~ "#{user.username} does not want to disclose his/her votes."
      refute html =~ "5.0"
    end
  end
end
