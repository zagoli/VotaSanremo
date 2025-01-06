defmodule VotaSanremo.Repo.Migrations.CreateEvenings do
  use Ecto.Migration

  def change do
    create table(:evenings) do
      add :number, :integer, null: false
      add :description, :string
      add :date, :date, null: false
      add :votes_start, :utc_datetime, null: false
      add :votes_end, :utc_datetime, null: false
      add :edition_id, references(:editions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:evenings, [:edition_id])
    create unique_index(:evenings, [:date])
    create unique_index(:evenings, [:number, :edition_id])
  end
end
