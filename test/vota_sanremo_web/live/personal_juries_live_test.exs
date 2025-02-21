defmodule VotaSanremoWeb.PersonalJuriesLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  alias VotaSanremo.Juries

  defp create_jury_for_user(%{user: user}) do
    jury = jury_fixture()
    Juries.add_member(jury, user)
    %{jury: jury}
  end

  defp found_jury(%{user: user}) do
    jury = jury_fixture(founder: user.id)
    %{founded_jury: jury}
  end

  describe "Personal Juries" do
    setup [:register_and_log_in_user, :create_jury_for_user, :found_jury]

    test "The page contains the juries founded by the user", %{conn: conn, founded_jury: jury} do
      {:ok, _live, html} = live(conn, ~p"/juries/personal")
      assert html =~ "You founded"
      assert html =~ "#{jury.name}"
    end

    test "The page does not show the title of the juries founded by the user if there are none",
         %{conn: conn, founded_jury: jury} do
      Juries.delete_jury(jury)
      {:ok, _live, html} = live(conn, ~p"/juries/personal")
      refute html =~ "Juries you have founded"
    end

    test "The page contains the juries the user is member of", %{conn: conn, jury: jury} do
      {:ok, _live, html} = live(conn, ~p"/juries/personal")
      assert html =~ "You are a member of"
      assert html =~ "#{jury.name}"
    end

    test "The page does not show the title of the juries the user is member of if there are none",
         %{conn: conn, jury: jury, user: user} do
      Juries.remove_member(jury, user)
      {:ok, _live, html} = live(conn, ~p"/juries/personal")
      refute html =~ "Juries you are a member of"
    end

    test "Clicking on a jury navigates to that jury page", %{
      conn: conn,
      founded_jury: founded_jury,
      jury: jury
    } do
      # Founded
      {:ok, live, _html} = live(conn, ~p"/juries/personal")

      element(live, "#founded-juries li div[role=button]")
      |> render_click()

      assert_redirect(live, ~p"/juries/#{founded_jury.id}")

      # Member
      {:ok, live, _html} = live(conn, ~p"/juries/personal")

      element(live, "#member-juries li div[role=button]")
      |> render_click()

      assert_redirect(live, ~p"/juries/#{jury.id}")
    end
  end
end
