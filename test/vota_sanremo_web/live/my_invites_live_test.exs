defmodule VotaSanremoWeb.MyInvitesLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  alias VotaSanremo.Juries

  defp create_invitations(%{user: user}) do
    pending = jury_invitation_fixture(%{user_id: user.id, status: :pending})
    accepted = jury_invitation_fixture(%{user_id: user.id, status: :accepted})
    declined = jury_invitation_fixture(%{user_id: user.id, status: :declined})
    %{invitations: {pending, accepted, declined}}
  end

  describe "My Invites" do
    setup [:register_and_log_in_user, :create_invitations]

    test "User can see their pending invites", %{conn: conn, invitations: {pending, _, _}} do
      {:ok, _live, html} = live(conn, ~p"/juries/my_invites")

      assert html =~ "My invites"
      jury_name = Juries.get_jury!(pending.jury_id).name
      assert html =~ jury_name
    end

    test "Users cannot see invites that are not pending", %{
      conn: conn,
      invitations: {pending, accepted, declined}
    } do
      # Delete the pending invitation for this test only
      Juries.delete_jury_invitation(pending)

      {:ok, live, html} = live(conn, ~p"/juries/my_invites")

      open_browser(live)
      assert html =~ "You have no pending invites"
      jury_name = Juries.get_jury!(accepted.jury_id).name
      refute html =~ jury_name
      jury_name = Juries.get_jury!(declined.jury_id).name
      refute html =~ jury_name
    end
  end
end
