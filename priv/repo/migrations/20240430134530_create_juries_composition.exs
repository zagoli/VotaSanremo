defmodule VotaSanremo.Repo.Migrations.CreateJuriesComposition do
  use Ecto.Migration

  def change do
    create table(:juries_composition) do
      add :jury_id, references(:juries)
      add :user_id, references(:users)
    end

    create unique_index(:juries_composition, [:jury_id, :user_id])
  end
end
