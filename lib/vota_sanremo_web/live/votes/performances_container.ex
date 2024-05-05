defmodule VotaSanremoWeb.Votes.PerformancesContainer do
  use Phoenix.Component

  attr :performances_type, :string, required: true
  def performances(assigns) do
    ~H"""
    <section>
      <h3 class="text-3xl"><%= @performances_type %></h3>
    </section>
    """
  end

end
