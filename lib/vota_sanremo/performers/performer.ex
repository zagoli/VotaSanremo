defmodule VotaSanremo.Performers.Performer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "performers" do
    field :name, :string

    has_many :performances, VotaSanremo.Performances.Performance

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(performer, attrs) do
    performer
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
