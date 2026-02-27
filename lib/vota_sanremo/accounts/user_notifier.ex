defmodule VotaSanremo.Accounts.UserNotifier do
  require Logger

  import Swoosh.Email

  alias VotaSanremo.Mailer
  alias VotaSanremo.Accounts.User

  @sender_email "votasanremo@zagoli.com"
  @sender_name "VotaSanremo"

  @confirm_account_ita_template_id 1
  @reset_password_ita_template_id 2
  @update_email_ita_template_id 3
  @user_invite_ita_template_id 4

  # Delivers an email using the given SendGrid template_id.
  defp deliver(recipient, template_id, data) when is_map(data) do
    email =
      new()
      |> to(recipient)
      |> from({@sender_name, @sender_email})
      |> put_provider_option(:template_id, template_id)
      |> put_provider_option(:params, data)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      Logger.info("Email sent to #{recipient}.")
      {:ok, email}
    else
      {:error, reason} ->
        Logger.error("Failed to send email to #{recipient}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(%User{} = user, url) do
    deliver(user.email, @confirm_account_ita_template_id, %{username: user.username, url: url})
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(%User{} = user, url) do
    deliver(user.email, @reset_password_ita_template_id, %{username: user.username, url: url})
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(%User{} = user, url) do
    deliver(user.email, @update_email_ita_template_id, %{username: user.username, url: url})
  end

  def deliver_user_invite(%User{} = user, params) when is_map(params) do
    deliver(user.email, @user_invite_ita_template_id, %{
      username: user.username,
      jury: params.jury_name,
      accept_url: params.accept_url,
      decline_url: params.decline_url,
      my_invites_url: params.my_invites_url
    })
  end
end
