defmodule VotaSanremo.Repo.Migrations.CreateJuriesComposition do
  use Ecto.Migration

  def change do
    create table(:juries_composition, primary_key: false) do
      add :jury_id, references(:juries, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create unique_index(:juries_composition, [:jury_id, :user_id])
  end
end
