defmodule VotaSanremoWeb.JuryLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.JuriesFixtures
  import VotaSanremo.AccountsFixtures
  import VotaSanremo.VotesFixtures
  alias VotaSanremo.Juries

  defp create_jury_and_votes(_) do
    jury = jury_fixture()
    user = user_fixture()
    Juries.add_member(jury, user)
    vote = vote_fixture(%{user_id: user.id})
    %{jury: jury, vote: vote}
  end

  describe "Jury Leaderboard" do
    setup [:create_jury_and_votes]

    test "It is possible to view the jury leaderboard", %{conn: conn, jury: jury, vote: vote} do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}")
      assert html =~ "Leaderboard"
      assert Floki.find(html, ".grid") |> Floki.text() =~ "#{vote.score}"
    end

    test "Guest user does not see the exit jury option", %{conn: conn, jury: jury} do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}")
      assert Floki.find(html, "#exit-jury") |> Enum.empty?()
    end
  end

  defp add_current_user_to_jury(%{user: user}) do
    jury = jury_fixture()
    Juries.add_member(jury, user)
    %{jury: jury}
  end

  describe "Jury member" do
    setup [:register_and_log_in_user, :add_current_user_to_jury]

    test "It is possible to exit from the jury", %{conn: conn, jury: jury, user: user} do
      {:ok, live, _html} = live(conn, ~p"/juries/#{jury.id}")

      live
      |> element("#exit-jury")
      |> render_click()

      assert_redirect(live, ~p"/juries")
      refute Juries.member?(jury, user)
    end
  end
end
