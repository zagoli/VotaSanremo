defmodule VotaSanremo.Repo do
  use Ecto.Repo,
    otp_app: :vota_sanremo,
    adapter: Ecto.Adapters.Postgres
end
