defmodule VotaSanremo.ScoresUtils do
  @moduledoc """
  This module provide utilities for dealing with scores.
  """

  @doc """
  Returns a list of acceptable scores as float.
  Acceptable scores start from 1, ends at 10 and they grow by 0.25 at a time.

  ## Examples

      iex> acceptable_scores
      [1, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 3.25, 3.5, 3.75, 4.0, 4.25, 4.5,
      4.75, 5.0, 5.25, 5.5, 5.75, 6.0, 6.25, 6.5, 6.75, 7.0, 7.25, 7.5, 7.75, 8.0,
      8.25, 8.5, 8.75, 9.0, 9.25, 9.5, 9.75, 10.0]
  """
  def acceptable_scores() do
    Stream.iterate(1, &(&1 + 0.25))
    |> Enum.take_while(&(&1 <= 10))
    |> Enum.to_list()
  end

  def to_string(score) do
    {int, decimal} = split_float(score)

    case decimal do
      +0.0 -> "#{int}"
      0.25 -> "#{int}+"
      0.5 -> "#{int}½"
      0.75 -> "#{int + 1}-"
    end
  end

  defp split_float(f) when is_float(f) do
    i = trunc(f)
    {i, f - i}
  end
end
