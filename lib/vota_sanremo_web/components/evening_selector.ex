defmodule VotaSanremoWeb.EveningSelector do
  use Phoenix.Component

  attr :evening, VotaSanremo.Evenings.Evening, required: true
  attr :selected, :boolean, default: false

  defp evening_button(assigns) do
    assigns =
      assign(
        assigns,
        :button_class,
        if assigns.selected do
          "bg-zinc-700 text-white hover:bg-zinc-600 px-4 text-lg font-semibold border border-black rounded"
        else
          "bg-white hover:bg-zinc-100 px-4 text-lg font-semibold border border-black rounded"
        end
      )

    ~H"""
    <button type="button" class={@button_class} phx-click="evening-selected" value={@evening.id}>
      {@evening.number}
    </button>
    """
  end

  attr :evenings, :list, default: []
  attr :selected_evening, VotaSanremo.Evenings.Evening, default: nil
  attr :class, :string, default: nil

  def evening_selector(assigns) do
    ~H"""
    <div class={["grid grid-rows-1 grid-flow-col gap-4", @class]}>
      <.evening_button
        :for={evening <- @evenings}
        evening={evening}
        selected={evening == @selected_evening}
      />
    </div>
    """
  end
end
