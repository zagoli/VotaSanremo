defmodule VotaSanremo.Juries.JuryInvite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jury_invites" do
    field :status, Ecto.Enum, values: [:accepted, :declined, :pending]

    belongs_to :user, VotaSanremo.Accounts.User
    belongs_to :jury, VotaSanremo.Juries.Jury

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(jury_invite, attrs) do
    jury_invite
    |> cast(attrs, [:status, :user_id, :jury_id])
    |> validate_required([:status, :user_id, :jury_id])
    |> unique_constraint([:jury_id, :user_id])
  end
end
