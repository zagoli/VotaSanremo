defmodule VotaSanremoWeb.InfoDataBadge do
  @moduledoc """
  Provides a badge with a label and a value.
  """
  use Phoenix.Component

  attr :label, :string, required: true
  attr :value_id, :string, default: nil, doc: "the html id of the value element"
  slot :inner_block, required: true, doc: "the text to display"

  def info_data_badge(assigns) do
    ~H"""
    <div class="w-24 h-32 p-3 bg-slate-200 rounded-md flex flex-col items-center overflow-hidden">
      <span class="text-slate-700 text-sm font-light text-center">{@label}</span>
      <span class="text-slate-800 font-semibold mt-2" id={@value_id}>
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end
end
