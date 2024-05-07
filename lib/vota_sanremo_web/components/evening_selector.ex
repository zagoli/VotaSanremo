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
          "bg-black text-white hover:bg-zinc-700 py-2 px-4 text-lg font-semibold border border-black"
        else
          "bg-white hover:bg-zinc-100 py-2 px-4 text-lg font-semibold border border-black"
        end
      )

    ~H"""
    <div class="grow">
      <button type="button" class={@button_class} phx-click="evening-selected" value={@evening.id}>
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
