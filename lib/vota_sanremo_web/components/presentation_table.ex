defmodule VotaSanremoWeb.PresentationTable do
  @moduledoc """
  Provides a table used to present some items and a property for each item.
  See the provided function documentation for more info.
  """
  use Phoenix.Component

  @doc ~S"""
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
    <div class="grid grid-cols-2 text-xl gap-y-6">
      <%= for item <- @items do %>
        <div class="font-semibold border-b">
          <%= render_slot(@name, item) %>
        </div>

        <div class="w-10 border-b text-center">
          <%= render_slot(@property, item) %>
        </div>
      <% end %>
    </div>
    """
  end
end
