defmodule VotaSanremoWeb.Admin.ManageEveningLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Evenings

  @impl true
  def mount(%{"id" => evening_id}, _session, socket) do
    evening = String.to_integer(evening_id) |> Evenings.get_evening_with_performances!()
    changeset = Evenings.change_evening(evening)

    {:ok,
     socket
     |> assign(:evening, evening)
     |> assign_form(changeset)}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def handle_event(
        "validate",
        %{"evening" => evening_params},
        %{assigns: %{evening: evening}} = socket
      ) do
    changeset =
      evening
      |> Evenings.change_evening(evening_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event(
        "save",
        %{"evening" => evening_params},
        %{assigns: %{evening: evening}} = socket
      ) do
    case Evenings.update_evening(evening, evening_params) do
      {:ok, evening} ->
        {:noreply,
         socket
         |> assign(evening: evening)
         |> put_flash(:info, "Evening updated successfully.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
