defmodule VotaSanremoWeb.PresentationTable do
  @moduledoc """
  Provides a table used to present some items and a property for each item.
  Provides also a badge-button.
  See the provided function documentation for more info.
  """
  use Phoenix.Component

  @doc """
  Renders a table with two columns.
  The first column should present the name of each item of the table.
  The second column should present a property related to the item, maybe with a phx-click attribute specified.

  ## Examples

      <.presentation_table items={@performances}>
        <:name :let={performance}> <%= performance.performer.name %> </:name>
        <:property :let={performance}> <%= perfomance.votes |> hd() |> Map.get(:score) %> </:property>
      </.presentation_table>
  """

  attr :items, :list, required: true
  slot :name, required: true, doc: "the slot for showing each item name"
  slot :property, required: true, doc: "the slot for showing the wanted property for each item"

  def presentation_table(assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-y-2 ">
      <%= for item <- @items do %>
        <div class="border-b border-base-300 py-2 flex items-center">
          {render_slot(@name, item)}
        </div>

        <div class="border-b border-base-300 py-2 text-right pr-3 flex items-center justify-end">
          {render_slot(@property, item)}
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a button with the look of a badge.

  ## Examples

      <.button_badge disabled>Click me</.button_badge>
  """
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def button_badge(assigns) do
    ~H"""
    <button
      type="button"
      class="badge badge-primary badge-outline font-semibold disabled:opacity-40"
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders a themed badge.

  ## Examples

      <.badge>Hi I'm a badge</.badge>
  """
  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span class="badge badge-primary badge-outline font-semibold">
      {render_slot(@inner_block)}
    </span>
    """
  end
end
