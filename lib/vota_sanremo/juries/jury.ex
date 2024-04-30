defmodule VotaSanremo.Juries.Jury do
  use Ecto.Schema
  import Ecto.Changeset

  schema "juries" do
    field :name, :string
    belongs_to :user, VotaSanremo.Accounts.User, foreign_key: :founder

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(jury, attrs) do
    jury
    |> cast(attrs, [:name, :founder])
    |> validate_required([:name, :founder])
    |> unsafe_validate_unique(:name, VotaSanremo.Repo)
    |> unique_constraint(:name)
  end
end
