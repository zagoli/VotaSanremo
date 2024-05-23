defmodule VotaSanremoWeb.LeaderboardLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias VotaSanremo.TestSetupFixtures

  @scores 1..5

  def create_votes(_) do
    {_, performer_name, first_performance_type, second_performance_type} =
      TestSetupFixtures.setup_for_avg_score_tests(@scores)

    %{
      performer_name: performer_name,
      first_performance_type: first_performance_type,
      second_performance_type: second_performance_type
    }
  end

  describe "Leaderboard" do
    setup [:create_votes, :register_and_log_in_user]

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
      assert not (html =~ Float.to_string(mean_score))
      mean_weighted_score = mean_score * Enum.sum(@scores)
      assert html =~ Float.to_string(mean_weighted_score)
    end
  end
end
