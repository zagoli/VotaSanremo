defmodule VotaSanremoWeb.UserLoginLive do
  use VotaSanremoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        {dgettext("accounts", "Log in to account")}
        <:subtitle>
          {dgettext("accounts", "Don't have an account?")}
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            {gettext("Sign up")}
          </.link>
          {dgettext("accounts", "for an account now.")}
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label={gettext("Email")} required />
        <.input field={@form[:password]} type="password" label={gettext("Password")} required />
        <:actions>
          <.input
            field={@form[:remember_me]}
            type="checkbox"
            label={dgettext("accounts", "Keep me logged in")}
          />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            {dgettext("accounts", "Forgot your password?")}
          </.link>
        </:actions>

        <:actions>
          <.button phx-disable-with={dgettext("accounts", "Logging in...")} class="w-full">
            {gettext("Log in")} <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
