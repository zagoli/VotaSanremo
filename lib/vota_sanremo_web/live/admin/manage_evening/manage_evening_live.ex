defmodule VotaSanremoWeb.Admin.ManageEveningLive do
  use VotaSanremoWeb, :live_view
  alias VotaSanremo.Evenings
  alias VotaSanremo.Performances.Performance
  alias VotaSanremo.Performances
  alias VotaSanremo.Performers

  @impl true
  def mount(%{"id" => evening_id}, _session, socket) do
    evening = String.to_integer(evening_id) |> Evenings.get_evening_with_performances!()
    evening_changeset = Evenings.change_evening(evening)
    performance_changeset = Performances.change_performance(%Performance{})

    {:ok,
     socket
     |> assign(:evening, evening)
     |> assign(:copy_from_evening_id, nil)
     |> assign_evening_form(evening_changeset)
     |> assign_performance_form(performance_changeset)
     |> assign_performers()
     |> assign_performance_types()
     |> assign_other_evenings()}
  end

  defp assign_evening_form(socket, changeset) do
    assign(socket, :evening_form, to_form(changeset))
  end

  defp assign_performance_form(socket, changeset) do
    assign(socket, :performance_form, to_form(changeset))
  end

  defp assign_performers(socket) do
    assign(socket,
      performers:
        Performers.list_performers()
        |> Enum.map(&{&1.name, &1.id})
    )
  end

  defp assign_performance_types(socket) do
    assign(socket,
      performance_types:
        Performances.list_performance_types()
        |> Enum.map(&{&1.type, &1.id})
    )
  end

  defp assign_other_evenings(socket) do
    assign(socket,
      other_evenings:
        Evenings.list_other_evenings(socket.assigns.evening)
        |> Enum.map(&{dgettext("evenings", "Evening %{number}", number: &1.number), &1.id})
    )
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

    {:noreply, assign_evening_form(socket, changeset)}
  end

  @impl true
  def handle_event(
        "save",
        %{"evening" => evening_params},
        %{assigns: %{evening: evening}} = socket
      ) do
    case Evenings.update_evening(evening, evening_params) do
      {:ok, evening} ->
        changeset = Evenings.change_evening(evening)

        {:noreply,
         socket
         |> assign(evening: evening)
         |> assign_evening_form(changeset)
         |> put_flash(:info, dgettext("evenings", "Evening updated successfully."))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_evening_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"performance" => performance_params},
        %{assigns: %{evening: evening}} = socket
      ) do
    performance_params = Map.put(performance_params, "evening_id", evening.id)

    case Performances.create_performance(performance_params) do
      {:ok, performance} ->
        evening = Evenings.get_evening_with_performances!(evening.id)
        changeset = Performances.change_performance(performance)

        {:noreply,
         socket
         |> assign(:evening, evening)
         |> assign_performance_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_performance_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event(
        "delete_performance",
        %{"value" => performance_id},
        %{assigns: %{evening: evening}} = socket
      ) do
    performance_id = String.to_integer(performance_id)
    performance_to_delete = evening.performances |> Enum.find(&(&1.id == performance_id))

    case Performances.delete_performance(performance_to_delete) do
      {:ok, _performance} ->
        evening = Evenings.get_evening_with_performances!(evening.id)

        {:noreply,
         socket
         |> assign(:evening, evening)
         |> put_flash(:info, dgettext("performances", "Performance deleted successfully."))}

      {:error, _changeset} ->
        {:noreply,
         socket |> put_flash(:error, dgettext("performances", "Could not delete performance."))}
    end
  end

  @impl true
  def handle_event(
        "select_copy_evening",
        %{"copy_evening" => %{"evening_id" => evening_id}},
        socket
      ) do
    {:noreply, assign(socket, :copy_from_evening_id, String.to_integer(evening_id))}
  end

  @impl true
  def handle_event(
        "confirm_copy_performances",
        _params,
        %{assigns: %{evening: evening, copy_from_evening_id: source_evening_id}} = socket
      ) do
    case Performances.copy_performances_from_evening(source_evening_id, evening.id) do
      {:ok, _performances} ->
        evening = Evenings.get_evening_with_performances!(evening.id)

        {:noreply,
         socket
         |> assign(:evening, evening)
         |> assign(:copy_from_evening_id, nil)
         |> put_flash(
           :info,
           dgettext("performances", "Performances copied successfully.")
         )}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(:copy_from_evening_id, nil)
         |> put_flash(
           :error,
           dgettext("performances", "Could not copy performances.")
         )}
    end
  end
end
