defmodule VotaSanremoWeb.EveningSelector do
  use Phoenix.Component
  use Gettext, backend: VotaSanremoWeb.Gettext

  attr :evening, VotaSanremo.Evenings.Evening, required: true
  attr :selected, :boolean, default: false

  defp evening_button(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "join-item btn flex-1",
        if(@selected, do: "btn-primary", else: "btn-ghost")
      ]}
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
    <div class={["join w-full", @class]}>
      <.evening_button
        :for={evening <- @evenings}
        evening={evening}
        selected={evening == @selected_evening}
      />
    </div>
    """
  end
end
