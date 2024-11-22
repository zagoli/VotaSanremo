defmodule VotaSanremoWeb.Admin.ManageEditionsLive do
  use VotaSanremoWeb, :live_view
  import VotaSanremoWeb.Admin.EditionEditor
  alias VotaSanremo.Editions

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_editions}
  end

  defp assign_editions(socket) do
    socket
    |> assign(:editions, Editions.list_editions_with_evenings())
  end

  def handle_info({VotaSanremoWeb.Admin.EditionEditorInternal, :edition_updated}, socket) do
    {:noreply, socket |> assign_editions}
  end

  def handle_event("new_edition", _params, socket) do
    new_name = get_fresh_name()

    case Editions.create_edition(%{
           name: new_name,
           start_date: Date.utc_today(),
           end_date: Date.utc_today()
         }) do
      {:ok, _} -> {:noreply, assign_editions(socket)}
      {:error, _} -> {:noreply, socket |> put_flash(:error, "Error creating the edition")}
    end
  end

  defp get_fresh_name() do
    base_name = "New edition"
    names = Editions.list_editions_names()

    # Creates a unique edition name by:
    # 1. Generating an infinite sequence of numbers (1, 2, 3, ...)
    Stream.iterate(1, &(&1 + 1))
    # 2. Converting numbers to potential names (e.g. "Edition", "Edition 2", "Edition 3")
    |> Stream.map(fn n -> if n == 1, do: base_name, else: "#{base_name} #{n}" end)
    # 3. Finding the first name that doesn't exist in the 'names' list
    |> Enum.find(fn name -> name not in names end)
  end
end
