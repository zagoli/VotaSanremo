defmodule VotaSanremoWeb.EveningSelector do
  use Phoenix.Component

  attr :evening, VotaSanremo.Evenings.Evening, required: true
  attr :selected, :boolean, default: false

  defp evening_button(assigns) do
    ~H"""
    <button
      type="button"
      class={"px-4 py-1 text-lg first:rounded-tl-lg last:rounded-tr-lg flex-1 border hover:bg-zinc-200" <>
            if assigns.selected do
              " bg-zinc-100 text-zinc-700 font-semibold"
            else
              ""
            end
      }
      phx-click="evening-selected"
      value={@evening.id}
    >
      {@evening.number}
    </button>
    """
  end

  attr :evenings, :list, default: []
  attr :selected_evening, VotaSanremo.Evenings.Evening, default: nil
  attr :class, :string, default: nil

  def evening_selector(assigns) do
    ~H"""
    <div class={["rounded-lg flex flex-col", @class]}>
      <div class="flex flex-1">
        <.evening_button
          :for={evening <- @evenings}
          evening={evening}
          selected={evening == @selected_evening}
        />
      </div>
      <span class="flex-1 py-1 rounded-b-lg text-center border-l border-r border-b">
        My message to you
      </span>
    </div>
    """
  end
end
