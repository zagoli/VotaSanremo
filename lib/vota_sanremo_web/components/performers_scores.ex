defmodule VotaSanremoWeb.PerformersScores do
  @moduledoc """
  Provides a component that shows performers scores.
  """
  use Phoenix.Component
  import VotaSanremoWeb.PresentationTable
  import VotaSanremoWeb.CoreComponents, only: [header: 1]

  attr :scores, :list, required: true

  def performers_scores(assigns) do
    ~H"""
    <div class="bg-zinc-100 border-4 border-zinc-500 rounded-lg p-3">
      <%= for {performance_type, scores} <- order_and_group_scores(@scores) do %>
        <.header class="mb-2">
          {performance_type}
        </.header>

        <div class="mb-7">
          <.presentation_table items={scores}>
            <:name :let={score_group}>{score_group.name}</:name>

            <:property :let={score_group}>
              <.badge>
                {score_to_string(score_group.score)}
              </.badge>
            </:property>
          </.presentation_table>
        </div>
      <% end %>
    </div>
    """
  end

  def order_and_group_scores(scores) do
    scores
    |> Enum.sort(&compare_scores(&1, &2))
    |> Enum.group_by(& &1.performance_type)
    # order group types
    |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
  end

  # When scores are equal (including both nil), compare names
  defp compare_scores(%{score: score, name: name1}, %{score: score, name: name2}),
    do: name1 <= name2

  # When one score is nil, nil goes last
  defp compare_scores(%{score: nil}, _), do: false
  defp compare_scores(_, %{score: nil}), do: true

  # When scores are different (and not nil), higher score goes first
  defp compare_scores(%{score: score1}, %{score: score2}),
    do: score1 >= score2

  defp score_to_string(nil), do: "-"

  defp score_to_string(score) when is_float(score) do
    score
    |> Float.round(2)
    |> Float.to_string()
  end
end
