defmodule VotaSanremoWeb.Admin.EditionEditor do
  @moduledoc """
  Component for editing a single edition and its evenings.
  """
  use Phoenix.Component
  alias VotaSanremo.Editions.Edition

  attr :edition, Edition, required: true

  def edition_editor(assigns) do
    ~H"""
    <.live_component
      module={VotaSanremoWeb.Admin.EditionEditorInternal}
      id={"edition-#{@edition.id}-editor"}
      edition={@edition}
    />
    """
  end
end

defmodule VotaSanremoWeb.Admin.EditionEditorInternal do
  alias VotaSanremo.Editions
  use VotaSanremoWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  def assign_form(socket) do
    changeset = Editions.change_edition(socket.assigns.edition)
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("update_edition", %{"edition" => params}, socket) do
    {:ok, _edition} = Editions.update_edition(socket.assigns.edition, params)
    notify_parent(:edition_updated)

    {:noreply, socket}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
