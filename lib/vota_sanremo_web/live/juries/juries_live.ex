defmodule VotaSanremoWeb.JuriesLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.SimpleList
  alias VotaSanremo.Juries

  def mount(_params, _session, socket) do
    IO.inspect(Gettext.get_locale(), label: "locale")
    {:ok, socket |> assign_top_juries()}
  end

  defp assign_top_juries(socket) do
    assign(socket, :top_juries, Juries.list_top_juries())
  end
end
