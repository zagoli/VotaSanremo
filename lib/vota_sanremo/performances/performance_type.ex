defmodule VotaSanremo.Performances.PerformanceType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "performancetypes" do
    field :type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(performance_type, attrs) do
    performance_type
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> unique_constraint(:type)
  end
end
