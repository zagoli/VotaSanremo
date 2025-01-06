defmodule VotaSanremoWeb.JuryMembersLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  import VotaSanremo.AccountsFixtures
  import VotaSanremo.JuriesFixtures

  defp create_juries(%{user: user}) do
    %{jury: jury_fixture(%{founder: user.id}), other_jury: jury_fixture()}
  end

  defp create_other_user(_) do
    %{other_user: user_fixture()}
  end

  defp create_invite(%{jury: jury, other_user: other_user}) do
    %{
      invite: jury_invite_fixture(%{jury_id: jury.id, user_id: other_user.id, status: :pending})
    }
  end

  describe "Guest user" do
    setup _ do
      %{jury: jury_fixture()}
    end

    test "The page loads successfully", %{conn: conn, jury: jury} do
      assert {:ok, _live, _html} = live(conn, ~p"/juries/#{jury.id}/members")
    end
  end

  describe "View founder and members" do
    alias VotaSanremo.Juries

    setup [:register_and_log_in_user, :create_juries]

    setup %{other_jury: jury} do
      first_user = user_fixture()
      second_user = user_fixture()

      Juries.add_member(jury, first_user)
      Juries.add_member(jury, second_user)

      %{members: [first_user, second_user]}
    end

    test "It is possible to view jury members", %{conn: conn, other_jury: jury, members: members} do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}/members")
      members_html = Floki.find(html, "#members") |> Floki.text()

      Enum.each(members, fn member ->
        assert members_html =~ member.username
      end)
    end

    test "When clicking on a member, the user is redirected to that member's profile", %{
      conn: conn,
      other_jury: jury,
      members: [member | _]
    } do
      {:ok, live, _html} = live(conn, ~p"/juries/#{jury.id}/members")

      live
      |> element("#members li div[role=button]", member.username)
      |> render_click()

      assert_redirect(live, ~p"/users/profile/#{member.id}")
    end
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
               |> element("a[title='Invite a user']")
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

    test "A founder cannot invite himself", %{conn: conn, user: user, jury: jury} do
      {:ok, live, _html} = live(conn, ~p"/juries/#{jury.id}/members/invite")

      refute live
             |> has_element?("#user-#{user.id} a", "Invite")
    end

    test "A founder cannot invite himself via direct link", %{conn: conn, user: user, jury: jury} do
      {:ok, _live, html} =
        live(conn, ~p"/juries/#{jury.id}/members/invite/#{user.id}")
        |> follow_redirect(conn, ~p"/juries/#{jury.id}/members")

      refute html =~ "User invited"
      assert html =~ "You cannot invite yourself!"
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

  describe "View sent invites" do
    setup [:register_and_log_in_user, :create_juries, :create_other_user, :create_invite]

    test "It is possible to view sent invites when founder", %{
      conn: conn,
      jury: jury,
      other_user: other_user
    } do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}/members")

      assert html =~ "Pending sent invites"
      invites_div = Floki.find(html, "#pending-invites") |> List.first() |> Floki.text()
      assert invites_div =~ other_user.username
    end

    test "When not a founder, the pending invites section is not present", %{
      conn: conn,
      other_jury: jury
    } do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}/members")

      refute html =~ "Pending invites"
    end
  end

  describe "Remove a member from a jury" do
    alias VotaSanremo.Juries
    setup [:register_and_log_in_user, :create_juries, :create_other_user, :create_invite]

    test "It is possible to remove a member from a jury when founder", %{
      conn: conn,
      jury: founded_jury,
      other_user: member
    } do
      Juries.add_member(founded_jury, member)

      {:ok, live, _html} = live(conn, ~p"/juries/#{founded_jury.id}/members")

      html =
        live
        |> element("#members li button[title='Remove member']")
        |> render_click()

      assert html =~ "Member removed!"

      refute html
             |> Floki.find("#members")
             |> Floki.text() =~ member.username
    end

    test "It is not possible to remove a member from a jury when not founder", %{
      conn: conn,
      other_jury: jury
    } do
      member = user_fixture()
      Juries.add_member(jury, member)

      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}/members")

      assert Enum.empty?(Floki.find(html, "#members li button[title='Remove member']"))
    end
  end
end
