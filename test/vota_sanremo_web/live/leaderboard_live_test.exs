defmodule VotaSanremoWeb.LeaderboardLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias VotaSanremo.{TestSetupFixtures, Votes}

  @scores 1..5

  def create_votes(_) do
    {edition_id, performer_name, first_performance_type, second_performance_type} =
      TestSetupFixtures.setup_for_avg_score_tests(@scores)

    %{
      edition_id: edition_id,
      performer_name: performer_name,
      first_performance_type: first_performance_type,
      second_performance_type: second_performance_type
    }
  end

  describe "Leaderboard" do
    setup [:create_votes]

    test "Leaderboard shows no votes message when there are no votes", %{conn: conn} do
      Votes.list_votes()
      |> Enum.each(fn vote -> Votes.delete_vote(vote) end)

      {:ok, _live, html} = live(conn, ~p"/leaderboard")
      assert html =~ "There are no votes to show!"
    end

    test "Leaderboard contains average scores for performers by default", %{
      conn: conn,
      performer_name: performer_name,
      first_performance_type: first_performance_type,
      second_performance_type: second_performance_type
    } do
      {:ok, _live, html} = live(conn, ~p"/leaderboard")
      assert html =~ performer_name
      assert html =~ first_performance_type
      assert html =~ second_performance_type
      mean_score = Enum.sum(@scores) / Enum.count(@scores)
      assert html =~ Float.to_string(mean_score)
    end

    test "User can switch to weighted average scores", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/leaderboard")

      html =
        live
        |> form("#weighted-score-flag-form")
        |> render_change(%{"weighted-scores-flag" => true})

      mean_score = Enum.sum(@scores) / Enum.count(@scores)
      refute html =~ Float.to_string(mean_score)
      mean_weighted_score = mean_score * Enum.sum(@scores)
      assert html =~ Float.to_string(mean_weighted_score)
    end

    test "Leaderboards updates when a user adds a new vote", %{conn: conn} do
      {:ok, live, html} = live(conn, ~p"/leaderboard")
      initial_mean_score = Enum.sum(@scores) / Enum.count(@scores)
      assert html =~ Float.to_string(initial_mean_score)
      refute html =~ "4.0"

      vote =
        Votes.list_votes()
        |> Enum.sort(&(&1.score <= &2.score))
        |> List.first()

      Votes.update_vote(vote, %{score: 6})

      send(live.pid, %{event: "vote_added", payload: :ok})
      :timer.sleep(10)

      assert render(live) =~ "4.0"
    end
  end
end
