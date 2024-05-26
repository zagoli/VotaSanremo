defmodule VotaSanremo.Repo.Migrations.CreatePerformers do
  use Ecto.Migration

  def change do
    create table(:performers) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:performers, [:name])
  end
end
