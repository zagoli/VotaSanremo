defmodule VotaSanremoWeb.JuriesLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  import VotaSanremo.AccountsFixtures
  alias VotaSanremo.Juries

  defp create_juries(_) do
    first_jury = jury_fixture()
    second_jury = jury_fixture()
    users = for _ <- 1..10, do: user_fixture()

    Enum.each(Enum.take(users, 5), fn user ->
      Juries.add_member(first_jury, user)
    end)

    Enum.each(users, fn user ->
      Juries.add_member(second_jury, user)
    end)

    %{juries: {first_jury, second_jury}}
  end

  describe "Logged user" do
    setup [:register_and_log_in_user]

    test "Should see the link to my juries", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/juries")
      assert html =~ "My Juries"
    end
  end

  describe "Guest user" do
    setup [:create_juries]

    test "Should not see the link to my juries", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/juries")
      refute html =~ "My Juries"
    end

    test "Should see the top juries", %{conn: conn, juries: {first_jury, second_jury}} do
      {:ok, live, _html} = live(conn, ~p"/juries")

      assert has_element?(live, "#top_juries li", second_jury.name)
      assert has_element?(live, "#top_juries li", "10 members")
      assert has_element?(live, "#top_juries li", first_jury.name)
      assert has_element?(live, "#top_juries li", "5 members")
    end

    test "Clicking on a jury should navigate to jury page", %{conn: conn, juries: {first_jury, _}} do
      {:ok, live, _html} = live(conn, ~p"/juries")

      element(live, "#top_juries li div[role=button]", first_jury.name)
      |> render_click()

      assert_redirect(live, ~p"/juries/#{first_jury.id}")
    end
  end

  describe "No juries" do
    test "It should render a message saying that there are no juries", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/juries")
      assert html =~ "There are no juries yet."
    end
  end
end
