defmodule VotaSanremoWeb.NewJuryLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  import VotaSanremo.AccountsFixtures

  defp create_jury(%{user: user}) do
    %{jury: jury_fixture(%{founder: user.id})}
  end

  defp create_other_user(_) do
    %{other_user: user_fixture()}
  end

  describe "Invite member" do
    setup [:register_and_log_in_user, :create_jury, :create_other_user]

    test "It is possible to invite a member to a jury when founder", %{
      conn: conn,
      jury: jury,
      other_user: other_user
    } do
      {:ok, live, _html} = live(conn, ~p"/juries/#{jury.id}/members")

      assert {:ok, live, _html} =
               live
               |> element("a", "Invite a user")
               |> render_click()
               |> follow_redirect(conn, ~p"/juries/#{jury.id}/members/invite")

      assert {:ok, _live, html} =
               live
               |> element("#user-#{other_user.id} a", "Invite")
               |> render_click()
               |> follow_redirect(conn, ~p"/juries/#{jury.id}/members/invite/#{other_user.id}")

      assert html =~ "User invited"
    end

    test "It is not possible to invite a member to a jury when not founder", %{conn: conn} do
      assert false
    end
  end
end
