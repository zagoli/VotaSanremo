defmodule VotaSanremo.Performances.Performance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "performances" do

    belongs_to :performance_type, VotaSanremo.Performances.PerformanceType
    belongs_to :evening, VotaSanremo.Evenings.Evening
    belongs_to :performer, VotaSanremo.Performers.Performer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(performance, attrs) do
    performance
    |> cast(attrs, [:performance_type_id, :evening_id, :performer_id])
    |> validate_required([:performance_type_id, :evening_id, :performer_id])
    |> unique_constraint([:performance_type_id, :evening_id, :performer_id])
  end
end
