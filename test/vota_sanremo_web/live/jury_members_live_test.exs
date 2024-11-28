defmodule VotaSanremoWeb.JuryMembersLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  import VotaSanremo.AccountsFixtures

  defp create_juries(%{user: user}) do
    %{jury: jury_fixture(%{founder: user.id}), other_jury: jury_fixture()}
  end

  defp create_other_user(_) do
    %{other_user: user_fixture()}
  end

  describe "Invite member" do
    setup [:register_and_log_in_user, :create_juries, :create_other_user]

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
               |> follow_redirect(conn, ~p"/juries/#{jury.id}/members")

      assert html =~ "User invited"
    end

    test "When not a founder, the button to invite a user is not present", %{
      conn: conn,
      other_jury: jury
    } do
      {:ok, live, _html} = live(conn, ~p"/juries/#{jury.id}/members")
      refute live |> element("a", "Invite a user") |> has_element?()
    end

    test "When not a founder, it is not possible to invite a user in a jury via direct link", %{
      conn: conn,
      other_jury: jury,
      other_user: other_user
    } do
      {:ok, _live, html} =
        live(conn, ~p"/juries/#{jury.id}/members/invite/#{other_user.id}")
        |> follow_redirect(conn, ~p"/juries/#{jury.id}/members")

      refute html =~ "User invited"
      assert html =~ "You are not allowed to invite a user!"
    end
  end
end
