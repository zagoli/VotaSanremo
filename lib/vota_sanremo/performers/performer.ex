defmodule VotaSanremo.Performers.Performer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "performes" do
    field :name, :string

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
