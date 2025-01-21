defmodule VotaSanremoWeb.PerformanceTypeLive.FormComponent do
  use VotaSanremoWeb, :live_component

  alias VotaSanremo.Performances

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="performance_type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:type]} type="text" label="Type" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Performance type</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{performance_type: performance_type} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Performances.change_performance_type(performance_type))
     end)}
  end

  @impl true
  def handle_event("validate", %{"performance_type" => performance_type_params}, socket) do
    changeset = Performances.change_performance_type(socket.assigns.performance_type, performance_type_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"performance_type" => performance_type_params}, socket) do
    save_performance_type(socket, socket.assigns.action, performance_type_params)
  end

  defp save_performance_type(socket, :edit, performance_type_params) do
    case Performances.update_performance_type(socket.assigns.performance_type, performance_type_params) do
      {:ok, performance_type} ->
        notify_parent({:saved, performance_type})

        {:noreply,
         socket
         |> put_flash(:info, "Performance type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_performance_type(socket, :new, performance_type_params) do
    case Performances.create_performance_type(performance_type_params) do
      {:ok, performance_type} ->
        notify_parent({:saved, performance_type})

        {:noreply,
         socket
         |> put_flash(:info, "Performance type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
