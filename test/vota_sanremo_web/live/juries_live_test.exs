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
      {:ok, _live, html} = live(conn, ~p"/juries")

      juries_html_items = Floki.find(html, "#top_juries li")

      assert Enum.count(juries_html_items) == 2

      assert juries_html_items |> Enum.at(0) |> Floki.text() =~ second_jury.name
      assert juries_html_items |> Enum.at(0) |> Floki.text() =~ "10 members"

      assert juries_html_items |> Enum.at(1) |> Floki.text() =~ first_jury.name
      assert juries_html_items |> Enum.at(1) |> Floki.text() =~ "5 members"
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
