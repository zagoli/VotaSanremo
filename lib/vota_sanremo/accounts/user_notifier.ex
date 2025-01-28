defmodule VotaSanremo.Accounts.UserNotifier do
  import Swoosh.Email

  alias VotaSanremo.Mailer
  alias VotaSanremo.Accounts.User

  @sender_email "votasanremo@zagoli.com"
  @sender_name "VotaSanremo"

  @confirm_account_ita_template_id "d-e73304d0aac24738bff098dfd2f7096e"
  @reset_password_ita_template_id "d-a77ba2379579432e8f5b8503db8df739"
  @update_email_ita_template_id "d-373c2c3c43eb4bb8a6ecd314d481cc94"

  # Delivers an email using the given SendGrid template_id.
  defp deliver(recipient, template_id, data) when is_map(data) do
    email =
      new()
      |> to(recipient)
      |> from({@sender_name, @sender_email})
      |> put_provider_option(:template_id, template_id)
      |> put_provider_option(:dynamic_template_data, data)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
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
end
