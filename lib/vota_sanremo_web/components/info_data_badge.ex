defmodule VotaSanremoWeb.InfoDataBadge do
  @moduledoc """
  Provides a badge with a label and a value.
  """
  use Phoenix.Component

  attr :label, :string, default: nil
  slot :inner_block, required: true, doc: "the text to display"

  def info_data_badge(assigns) do
    ~H"""
    <div class="w-14 h-20 m-2 bg-slate-200 rounded-md flex flex-col items-center justify-center">
      <%= if @label do %>
        <span class="text-slate-700 text-sm font-light"> <%= @label %> </span>
      <% end %>
      <span class="text-slate-800 font-semibold"> {render_slot(@inner_block)} </span>
    </div>
    """
  end

end
