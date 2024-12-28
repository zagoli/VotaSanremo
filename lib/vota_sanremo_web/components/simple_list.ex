defmodule VotaSanremoWeb.SimpleList do
  use Phoenix.Component

  @doc """
  Renders a simple scrollable list.
  """
  attr :id, :string, default: ""
  attr :item_click, :any, default: nil, doc: "the function for handling phx-click on each item"
  attr :class, :string, default: ""

  slot :item do
    attr :click_target, :any, doc: "the item that will be passed to `item_click` and actions"

    attr :item_id, :string,
      doc: "The optional id of the html element containing the item and actions"
  end

  slot :action, doc: "The actions for each item"

  def simple_list(assigns) do
    ~H"""
    <ul class={"mt-4 border border-zinc-300 rounded-lg divide-y divide-zinc-100 " <> @class} id={@id}>
      <li
        :for={item <- @item}
        class="flex items-center justify-between text-zinc-900 py-2 px-4"
        id={Map.get(item, :item_id)}
      >
        <div
          class="flex-1"
          phx-click={@item_click && @item_click.(item.click_target)}
          role={if @item_click, do: "button"}
        >
          {render_slot(item)}
        </div>
        <div :if={@action != []}>
          {render_slot(@action, item.click_target)}
        </div>
      </li>
    </ul>
    """
  end
end
