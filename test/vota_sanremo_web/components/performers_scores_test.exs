defmodule VotaSanremoWeb.PerformersScoresTest do
  use ExUnit.Case, async: true

  describe "order_and_group_score" do
    setup do
      %{
        scores: [
          %{name: "B", score: nil, performance_type: "P1"},
          %{name: "A", score: nil, performance_type: "P1"},
          %{name: "C", score: 5, performance_type: "P1"},
          %{name: "D", score: 10, performance_type: "P1"},
          %{name: "A", score: 10, performance_type: "P2"}
        ]
      }
    end

    test "performance type groups are ordered in ascending order by performance type name", %{
      scores: scores
    } do
      [first_group, second_group] = VotaSanremoWeb.PerformersScores.order_and_group_scores(scores)

      assert elem(first_group, 0) == "P1"
      assert elem(second_group, 0) == "P2"
    end

    test "scores are in the correct order", %{
      scores: scores
    } do
      [{_, ordered_scores} | _] = VotaSanremoWeb.PerformersScores.order_and_group_scores(scores)

      expected_performers_names = ["D", "C", "A", "B"]
      performers_names = Enum.map(ordered_scores, & &1.name)

      assert performers_names == expected_performers_names
    end
  end
end
