defmodule VotaSanremo.Editions.Edition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "editions" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(edition, attrs) do
    edition
    |> cast(attrs, [:name, :start_date, :end_date])
    |> validate_required([:name, :start_date, :end_date])
    |> unsafe_validate_unique(:name, VotaSanremo.Repo)
    |> unique_constraint(:name)
  end
end
