defmodule VotaSanremo.Repo.Migrations.CreatePerformances do
  use Ecto.Migration

  def change do
    create table(:performances) do
      add :performance_type_id, references(:performance_types, on_delete: :nothing)
      add :evening_id, references(:evenings, on_delete: :nothing)
      add :performer_id, references(:performers, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:performances, [:performance_type_id])
    create index(:performances, [:evening_id])
    create index(:performances, [:performer_id])
    create unique_index(:performances, [:performance_type_id, :evening_id, :performer_id])
  end
end
