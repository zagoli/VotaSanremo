defmodule VotaSanremoWeb.UserRegistrationLive do
  use VotaSanremoWeb, :live_view

  require Logger

  alias VotaSanremo.Accounts
  alias VotaSanremo.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        {dgettext("accounts", "Register for an account")}
        <:subtitle>
          {dgettext("accounts", "Already registered?")}
          <.link navigate={~p"/users/log_in"} class="font-semibold text-primary hover:underline">
            {dgettext("accounts", "Log in")}
          </.link>
          {dgettext("accounts", "to your account now.")}
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          {dgettext("accounts", "Oops, something went wrong! Please check the errors below.")}
        </.error>

        <.input
          field={@form[:username]}
          type="text"
          label={dgettext("accounts", "Username")}
          phx-debounce="blur"
          required
        />
        <.input
          field={@form[:email]}
          type="email"
          label={dgettext("accounts", "Email")}
          phx-debounce="blur"
          required
        /> <.input field={@form[:password]} type="password" label={dgettext("accounts", "Password")} required />
        <:actions>
          <.button phx-disable-with={dgettext("accounts", "Creating account...")} class="w-full">
            {dgettext("accounts", "Create an account")}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    with {:ok, user} <- Accounts.register_user(user_params),
         :ok <- deliver_confirmation_instructions(user) do
      changeset = Accounts.change_user_registration(user)
      Logger.info("Confirmation instructions sent to #{user.username}")

      {:noreply,
       socket
       |> assign(trigger_submit: true)
       |> assign_form(changeset)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}

      {:delivery_error, user} ->
        Logger.error("Failed to deliver confirmation instructions to #{user.username}")
        Accounts.delete_user(user)

        {:noreply,
         socket
         |> put_flash(
           :error,
           dgettext(
             "accounts",
             "There was an error creating your account, please try again later."
           )
         )}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp deliver_confirmation_instructions(user) do
    case Accounts.deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}")) do
      {:ok, _mail} -> :ok
      {:error, _} -> {:delivery_error, user}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
