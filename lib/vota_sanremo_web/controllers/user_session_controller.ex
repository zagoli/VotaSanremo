defmodule VotaSanremoWeb.UserSessionController do
  use VotaSanremoWeb, :controller
  use Gettext, backend: VotaSanremoWeb.Gettext

  alias VotaSanremo.Accounts
  alias VotaSanremoWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(
      conn,
      params,
      gettext(
        "Account created successfully! A confirmation email was sent to your email address."
      )
    )
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, gettext("Password updated successfully!"))
  end

  def create(conn, params) do
    create(conn, params, gettext("Welcome back!"))
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, dgettext("errors", "Invalid email or password"))
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, gettext("Logged out successfully."))
    |> UserAuth.log_out_user()
  end

  def delete_account(%{assigns: %{current_user: user}} = conn, _params) do
    case Accounts.delete_user(user) do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Account deleted successfully."))
        |> UserAuth.log_out_user()

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("An error occurred while deleting your account."))
        |> redirect(to: ~p"/users/settings")
    end
  end
end
