defmodule VotaSanremo.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset
  alias VotaSanremo.ScoresUtils

  schema "votes" do
    field :score, :float
    field :multiplier, :float
    belongs_to :user, VotaSanremo.Accounts.User
    belongs_to :performance, VotaSanremo.Performances.Performance

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:score, :multiplier, :user_id, :performance_id])
    |> validate_required([:score, :multiplier, :user_id, :performance_id])
    |> validate_inclusion(:score, ScoresUtils.acceptable_scores)
    |> unique_constraint([:user_id, :performance_id])
  end
end
