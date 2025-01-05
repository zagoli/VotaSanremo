defmodule VotaSanremoWeb.JuryLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  import VotaSanremo.AccountsFixtures
  import VotaSanremo.VotesFixtures
  import VotaSanremo.EditionsFixtures
  alias VotaSanremo.Juries

  defp create_jury_and_votes(_) do
    founder = user_fixture()
    jury = jury_fixture(%{founder: founder.id})
    user = user_fixture()
    Juries.add_member(jury, user)
    vote = vote_fixture(%{user_id: user.id})
    %{jury: jury, founder: founder, vote: vote}
  end

  describe "Guest users" do
    setup [:create_jury_and_votes]

    test "Can view the jury leaderboard", %{conn: conn, jury: jury, vote: vote} do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}")
      assert html =~ "Leaderboard"
      assert Floki.find(html, ".grid") |> Floki.text() =~ "#{vote.score}"
    end

    test "Do not see the exit jury option", %{conn: conn, jury: jury} do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}")
      assert Floki.find(html, "#exit-jury") |> Enum.empty?()
    end

    test "Can view the founder", %{conn: conn, founder: founder, jury: founded_jury} do
      {:ok, _live, html} = live(conn, ~p"/juries/#{founded_jury.id}")

      assert html =~ "Founded by"
      assert html =~ founder.username
    end
  end

  defp add_current_user_to_jury(%{user: user}) do
    edition_fixture()
    jury = jury_fixture()
    jury_invite_fixture(%{user_id: user.id, jury_id: jury.id, status: :accepted})
    Juries.add_member(jury, user)
    %{jury: jury}
  end

  describe "Jury members" do
    setup [:register_and_log_in_user, :add_current_user_to_jury]

    test "Can exit from the jury", %{conn: conn, jury: jury, user: user} do
      {:ok, live, _html} = live(conn, ~p"/juries/#{jury.id}")

      assert {:ok, _live, html} =
               live
               |> element("#exit-jury")
               |> render_click()
               |> follow_redirect(conn, ~p"/juries")

      assert html =~ "You have successfully exited the jury!"
      refute Juries.member?(jury, user)
    end
  end
end
