defmodule VotaSanremoWeb.NewJuryLive do
  use VotaSanremoWeb, :live_view

  alias VotaSanremo.Juries
  alias VotaSanremo.Juries.Jury

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_form(Juries.change_jury(%Jury{}))}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("validate", %{"jury" => jury_params}, socket) do
    changeset = Juries.change_jury(%Jury{}, jury_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"jury" => jury_params}, socket) do
    jury_params = jury_params_with_founder(socket, jury_params)

    case Juries.create_jury(jury_params) do
      {:ok, jury} ->
        {:noreply, push_navigate(socket, to: ~p"/juries/#{jury.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp jury_params_with_founder(%{assigns: %{current_user: user}}, jury_params) do
    Map.put(jury_params, "founder", user.id)
  end
end
