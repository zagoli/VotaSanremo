defmodule VotaSanremoWeb.EveningSelector do
  use Phoenix.Component

  attr :evening, VotaSanremo.Evenings.Evening, required: true
  attr :selected, :boolean, default: false
  attr :now, DateTime, default: DateTime.utc_now()

  defp evening_button(assigns) do
    ~H"""
    <div class="grow">
      <button
        type="button"
        class={
          if @selected do
            "bg-black text-white hover:bg-zinc-700 py-2 px-4 text-lg font-semibold border border-black"
          else
            "bg-white hover:bg-zinc-100 py-2 px-4 text-lg font-semibold border border-black"
          end
        }
        phx-click="evening-selected"
        value={@evening.id}
        class="ml-2 mr-2"
        disabled={
          DateTime.compare(@now, @evening.votes_start) == :lt or
            DateTime.compare(@now, @evening.votes_end) == :gt
        }
      >
        <%= @evening.number %>
      </button>
    </div>
    """
  end

  attr :evenings, :list, default: []
  attr :selected_evening, VotaSanremo.Evenings.Evening, default: nil
  attr :class, :string, default: nil

  def evening_selector(assigns) do
    ~H"""
    <div class={["flex", @class]}>
      <.evening_button
        :for={evening <- @evenings}
        evening={evening}
        selected={evening == @selected_evening}
      />
    </div>
    """
  end
end
