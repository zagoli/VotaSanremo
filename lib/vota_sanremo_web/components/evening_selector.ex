defmodule VotaSanremoWeb.EveningSelector do
  use Phoenix.Component
  use Gettext, backend: VotaSanremoWeb.Gettext

  attr :evening, VotaSanremo.Evenings.Evening, required: true
  attr :selected, :boolean, default: false

  defp evening_button(assigns) do
    ~H"""
    <button
      type="button"
      class={"px-4 py-1 text-lg first:rounded-l-lg last:rounded-r-lg flex-1 border hover:bg-zinc-200" <>
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
