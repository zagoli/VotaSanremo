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
  alias VotaSanremo.Editions.Edition
  alias VotaSanremo.Evenings
  use VotaSanremoWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()
     |> assign_editing(false)}
  end

  def assign_form(socket) do
    changeset = Editions.change_edition(socket.assigns.edition)
    assign(socket, :form, to_form(changeset, id: "edition-form-#{socket.assigns.edition.id}"))
  end

  def assign_editing(socket, editing) when is_boolean(editing) do
    assign(socket, :editing, editing)
  end

  def handle_event("editing", _params, socket) do
    {:noreply, assign_editing(socket, true)}
  end

  def handle_event("update_edition", %{"edition" => params}, socket) do
    {:ok, _edition} = Editions.update_edition(socket.assigns.edition, params)
    notify_parent(:edition_updated)

    {:noreply,
     socket
     |> assign_editing(false)}
  end

  def handle_event("delete_edition", _params, socket) do
    {:ok, _edition} = Editions.delete_edition(socket.assigns.edition)
    notify_parent(:edition_updated)

    {:noreply, socket}
  end

  def handle_event("add_evening", _params, socket) do
    new_edition_attrs = %{
      edition_id: socket.assigns.edition.id,
      number: get_unique_evening_number(socket.assigns.edition),
      date: get_unique_evening_date(),
      votes_start: DateTime.utc_now(),
      votes_end: DateTime.utc_now()
    }

    {:ok, _evening} = Evenings.create_evening(new_edition_attrs)
    notify_parent(:edition_updated)

    {:noreply, socket}
  end

  def handle_event(
        "delete_evening",
        %{"value" => evening_id},
        %{assigns: %{edition: edition}} = socket
      ) do
    evening_id = String.to_integer(evening_id)
    evening_to_delete = Enum.find(edition.evenings, &(&1.id == evening_id))
    {:ok, _evening} = Evenings.delete_evening(evening_to_delete)
    notify_parent(:edition_updated)

    {:noreply, socket}
  end

  defp get_unique_evening_number(edition = %Edition{}) do
    latest_number =
      Enum.map(edition.evenings, & &1.number)
      |> Enum.max(&Kernel.>=/2, fn -> 0 end)

    latest_number + 1
  end

  defp get_unique_evening_date() do
    case Evenings.get_latest_evening_date() do
      nil -> Date.utc_today()
      date -> Date.add(date, 1)
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
