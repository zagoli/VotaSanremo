defmodule VotaSanremo.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :score, :float, null: false
      add :multiplier, :float, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :performance_id, references(:performances, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:votes, [:user_id])
    create index(:votes, [:performance_id])
    create unique_index(:votes, [:user_id, :performance_id])
  end
end
