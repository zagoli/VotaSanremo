defmodule VotaSanremo.SwooshFailingAdapter do
  @moduledoc """
  A Swoosh adapter that always fails to deliver emails.
  Useful for testing error handling when email delivery fails.
  """
  @behaviour Swoosh.Adapter

  def validate_config(_config), do: :ok
  def deliver(_email, _config), do: {:error, :delivery_failed}
end
