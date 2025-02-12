defmodule VotaSanremoWeb.Admin.ManagePerformersLive.FormComponent do
  use VotaSanremoWeb, :live_component

  alias VotaSanremo.Performers

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>{dgettext("performers", "Add or edit a performer.")}</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="performer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label={gettext("Name")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}>
            {dgettext("performers", "Save Performer")}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{performer: performer} = assigns, socket) do
    changeset = Performers.change_performer(performer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"performer" => performer_params}, socket) do
    changeset =
      socket.assigns.performer
      |> Performers.change_performer(performer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"performer" => performer_params}, socket) do
    save_performer(socket, socket.assigns.action, performer_params)
  end

  defp save_performer(socket, :edit, performer_params) do
    case Performers.update_performer(socket.assigns.performer, performer_params) do
      {:ok, performer} ->
        notify_parent({:saved, performer})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("performers", "Performer updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_performer(socket, :new, performer_params) do
    case Performers.create_performer(performer_params) do
      {:ok, performer} ->
        notify_parent({:saved, performer})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("performers", "Performer created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
