defmodule VotaSanremo.Repo.Migrations.CreatePerformes do
  use Ecto.Migration

  def change do
    create table(:performes) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:performes, [:name])
  end
end
