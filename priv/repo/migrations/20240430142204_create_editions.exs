defmodule VotaSanremo.Repo.Migrations.CreateEditions do
  use Ecto.Migration

  def change do
    create table(:editions) do
      add :name, :string, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:editions, [:name])
  end
end
