defmodule VotaSanremoWeb.LeaderboardLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias VotaSanremo.{TestSetupFixtures, Votes}

  @scores 1..5

  defp create_votes(_) do
    {edition_id, performer_name, first_performance_type, second_performance_type} =
      TestSetupFixtures.setup_for_avg_score_tests(@scores)

    %{
      edition_id: edition_id,
      performer_name: performer_name,
      first_performance_type: first_performance_type,
      second_performance_type: second_performance_type
    }
  end

  defp get_avg(scores) do
    Enum.sum(scores) / Enum.count(scores)
  end

  defp get_weighted_avg(_) do
    # All votes are equal, so they should be all 100
    100
  end

  describe "Leaderboard" do
    setup [:create_votes]

    test "Leaderboard renders hyphens when there are no votes", %{
      conn: conn,
      performer_name: performer_name
    } do
      # Delete votes created during test setup
      Votes.list_votes()
      |> Enum.each(fn vote -> Votes.delete_vote(vote) end)

      {:ok, _live, html} = live(conn, ~p"/leaderboard")
      assert html =~ performer_name
      assert html =~ "-"
    end

    test "Leaderboard contains performers and performance types", %{
      conn: conn,
      performer_name: performer_name,
      first_performance_type: first_performance_type,
      second_performance_type: second_performance_type
    } do
      {:ok, _live, html} = live(conn, ~p"/leaderboard")
      assert html =~ performer_name
      assert html =~ first_performance_type
      assert html =~ second_performance_type
    end

    test "Leaderboard contains weighted scores for performers by default", %{
      conn: conn
    } do
      {:ok, _live, html} = live(conn, ~p"/leaderboard")
      mean_weighted_score = get_weighted_avg(@scores)
      assert html =~ Integer.to_string(mean_weighted_score)
    end

    test "Weighted checkbox is checked by default", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/leaderboard")
      assert Floki.attribute(html, "input[name=weighted-scores-flag]", "checked") == ["checked"]
    end

    test "User can switch to average average scores", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/leaderboard")

      html =
        live
        |> form("#weighted-score-flag-form")
        |> render_change(%{"weighted-scores-flag" => false})

      mean_score = get_avg(@scores)
      assert html =~ Float.to_string(mean_score)
    end

    test "Leaderboards updates when a user adds a new vote", %{conn: conn} do
      {:ok, live, html} = live(conn, ~p"/leaderboard")
      initial_weighted_score = get_weighted_avg(@scores)
      assert html =~ Integer.to_string(initial_weighted_score)

      vote =
        Votes.list_votes()
        |> Enum.sort(&(&1.score <= &2.score))
        |> List.first()

      Votes.update_vote(vote, %{score: 6})

      send(live.pid, %{event: "vote_changed", payload: :ok})
      Process.sleep(10)

      assert render(live) =~
               get_weighted_avg(@scores |> Enum.to_list() |> List.replace_at(0, 6))
               |> Integer.to_string()
    end
  end

  describe "Leaderboard with no performers" do
    import VotaSanremo.EditionsFixtures

    setup _ do
      edition_fixture()
      :ok
    end

    test "It should show a message stating that there are no votes", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/leaderboard")
      assert html =~ "There are no artists yet."
    end
  end
end
