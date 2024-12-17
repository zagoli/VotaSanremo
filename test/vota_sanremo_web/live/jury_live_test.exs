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
    setup [:register_and_log_in_user, :create_jury_and_votes]

    test "It is possible to view the jury leaderboard", %{conn: conn, jury: jury, vote: vote} do
      {:ok, _live, html} = live(conn, ~p"/juries/#{jury.id}")
      assert html =~ "Leaderboard"
      assert Floki.find(html, ".grid") |> Floki.text() =~ "#{vote.score}"
    end
  end
end
