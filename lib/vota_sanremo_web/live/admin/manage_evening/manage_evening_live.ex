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
     |> assign_evening_form(evening_changeset)
     |> assign_performance_form(performance_changeset)
     |> assign_performers()
     |> assign_performance_types()}
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
         |> put_flash(:info, gettext("Evening updated successfully."))}

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
         |> assign_performance_form(changeset)
         |> put_flash(:info, gettext("Performance added successfully."))}

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
         |> put_flash(:info, gettext("Performance deleted successfully."))}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, gettext("Could not delete performance."))}
    end
  end
end
