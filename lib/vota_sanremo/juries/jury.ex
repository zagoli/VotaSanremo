defmodule VotaSanremo.Juries.Jury do
  use Ecto.Schema
  import Ecto.Changeset

  schema "juries" do
    field :name, :string

    belongs_to :user, VotaSanremo.Accounts.User, foreign_key: :founder

    has_many :jury_invites, VotaSanremo.Juries.JuryInvite

    many_to_many :members, VotaSanremo.Accounts.User, join_through: "juries_composition"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(jury, attrs) do
    jury
    |> cast(attrs, [:name, :founder])
    |> validate_required([:name, :founder])
    |> validate_length(:name, max: 160)
    |> unsafe_validate_unique(:name, VotaSanremo.Repo)
    |> unique_constraint(:name)
  end
end
