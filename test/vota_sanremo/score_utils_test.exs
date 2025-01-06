defmodule VotaSanremo.ScoreUtilsTest do
  use ExUnit.Case
  alias VotaSanremo.ScoresUtils

  describe "score utils" do
    test "acceptable_scores/0 produces the right scores" do
      scores = ScoresUtils.acceptable_scores()

      assert scores == [
               1,
               1.25,
               1.5,
               1.75,
               2.0,
               2.25,
               2.5,
               2.75,
               3.0,
               3.25,
               3.5,
               3.75,
               4.0,
               4.25,
               4.5,
               4.75,
               5.0,
               5.25,
               5.5,
               5.75,
               6.0,
               6.25,
               6.5,
               6.75,
               7.0,
               7.25,
               7.5,
               7.75,
               8.0,
               8.25,
               8.5,
               8.75,
               9.0,
               9.25,
               9.5,
               9.75,
               10.0
             ]
    end

    test "to_string/1 correctly converts a float score to string" do
      Enum.each(1..10, fn int_score ->
        assert ScoresUtils.to_string(int_score + 0.0) == "#{int_score}"
        assert ScoresUtils.to_string(int_score + 0.25) == "#{int_score}+"
        assert ScoresUtils.to_string(int_score + 0.5) == "#{int_score}½"
        assert ScoresUtils.to_string(int_score + 0.75) == "#{int_score + 1}-"
      end)
    end
  end
end
