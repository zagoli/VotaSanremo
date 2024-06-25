defmodule VotaSanremo.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VotaSanremo.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "Hello world!"
  def unique_username, do: "username#{System.unique_integer([:positive])}"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      username: unique_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> VotaSanremo.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def confirm_user(%VotaSanremo.Accounts.User{} = user) do
    case VotaSanremo.Repo.transaction(VotaSanremo.Accounts.confirm_user_multi(user)) do
      {:ok, %{user: user}} -> {:ok, user}
      _ -> :error
    end
  end
end
