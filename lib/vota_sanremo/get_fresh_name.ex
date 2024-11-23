defmodule VotaSanremo.GetFreshName do
  @doc """
  Generates a unique name by appending a number to the base name if necessary.

  ## Parameters

    - base_name: String that serves as the base for generating unique names
    - names: List of existing names to check against for uniqueness

  ## Examples

      iex> get_fresh_name("Edition", ["Edition", "Edition 2"])
      "Edition 3"

      iex> get_fresh_name("New Series", ["Something else"])
      "New Series"
  """
  def get_fresh_name(base_name, names) do
    # Creates a unique edition name by:
    # 1. Generating an infinite sequence of numbers (1, 2, 3, ...)
    Stream.iterate(1, &(&1 + 1))
    # 2. Converting numbers to potential names (e.g. "Edition", "Edition 2", "Edition 3")
    |> Stream.map(fn n -> if n == 1, do: base_name, else: "#{base_name} #{n}" end)
    # 3. Finding the first name that doesn't exist in the 'names' list
    |> Enum.find(fn name -> name not in names end)
  end
end
