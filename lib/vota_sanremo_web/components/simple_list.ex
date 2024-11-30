defmodule VotaSanremoWeb.SimpleList do
  use Phoenix.Component

  @doc """
  Renders a simple scrollable list.
  """
  attr :id, :string, default: ""
  attr :item_click, :any, default: nil, doc: "the function for handling phx-click on each item"
  attr :class, :string, default: ""

  slot :item do
    attr :click_target, :any, doc: "the item that will be passed to `item_click`"
  end

  def simple_list(assigns) do
    ~H"""
    <ul class={"mt-4 border border-zinc-300 rounded-lg divide-y divide-zinc-100 " <> @class} id={@id}>
      <li
        :for={item <- @item}
        phx-click={@item_click && @item_click.(item.click_target)}
        role={if @item_click, do: "button", else: "listitem"}
        class="text-zinc-900 pt-2 pb-2 pl-4"
      >
        <%= render_slot(item) %>
      </li>
    </ul>
    """
  end
end
