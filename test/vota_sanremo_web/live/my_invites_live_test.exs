defmodule VotaSanremoWeb.MyInvitesLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  alias VotaSanremo.Juries

  defp create_invites(%{user: user}) do
    pending = jury_invite_fixture(%{user_id: user.id, status: :pending})
    accepted = jury_invite_fixture(%{user_id: user.id, status: :accepted})
    declined = jury_invite_fixture(%{user_id: user.id, status: :declined})
    %{invites: {pending, accepted, declined}}
  end

  describe "My Invites" do
    setup [:register_and_log_in_user, :create_invites]

    test "users can see their pending invites", %{conn: conn, invites: {pending, _, _}} do
      {:ok, _live, html} = live(conn, ~p"/juries/my_invites")

      assert html =~ "My invites"
      jury_name = Juries.get_jury!(pending.jury_id).name
      assert html =~ jury_name
    end

    test "users cannot see invites that are not pending", %{
      conn: conn,
      invites: {pending, accepted, declined}
    } do
      # Delete the pending invite for this test only
      Juries.delete_jury_invite(pending)

      {:ok, _live, html} = live(conn, ~p"/juries/my_invites")

      assert html =~ "You have no pending invites"
      jury_name = Juries.get_jury!(accepted.jury_id).name
      refute html =~ jury_name
      jury_name = Juries.get_jury!(declined.jury_id).name
      refute html =~ jury_name
    end

    test "users can accept pending invites", %{
      conn: conn,
      invites: {pending, _, _}
    } do
      {:ok, live, html} = live(conn, ~p"/juries/my_invites")
      assert html =~ "Accept"
      assert html =~ "Decline"

      html =
        live
        |> element("#invites a", "Accept")
        |> render_click()

      jury_name = Juries.get_jury!(pending.jury_id).name
      assert html =~ "Invite accepted! You are now part of #{jury_name}"
      refute Floki.find(html, "#invites") |> Floki.text() =~ jury_name
    end

    test "users can decline pending invites", %{
      conn: conn,
      invites: {pending, _, _}
    } do
      {:ok, live, _html} = live(conn, ~p"/juries/my_invites")

      html =
        live
        |> element("#invites a", "Decline")
        |> render_click()

      assert html =~ "Invite declined."
      jury_name = Juries.get_jury!(pending.jury_id).name
      refute Floki.find(html, "#invites") |> Floki.text() =~ jury_name
    end
  end
end
