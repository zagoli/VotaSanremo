defmodule VotaSanremo.Evenings.Evening do
  use Ecto.Schema
  import Ecto.Changeset

  schema "evenings" do
    field :date, :date
    field :description, :string
    field :number, :integer
    field :votes_start, :utc_datetime
    field :votes_end, :utc_datetime

    has_many :performances, VotaSanremo.Performances.Performance

    belongs_to :edition, VotaSanremo.Editions.Edition

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(evening, attrs) do
    evening
    |> cast(attrs, [:number, :description, :date, :votes_start, :votes_end, :edition_id])
    |> validate_required([:number, :date, :votes_start, :votes_end, :edition_id])
    |> validate_unique_constraints()
  end

  def validate_unique_constraints(changeset) do
    changeset
    |> unsafe_validate_unique(:date, VotaSanremo.Repo)
    |> unique_constraint(:date)
    |> unsafe_validate_unique([:number, :edition_id], VotaSanremo.Repo)
    |> unique_constraint([:number, :edition_id])
  end
end
