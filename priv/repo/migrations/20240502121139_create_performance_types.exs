defmodule VotaSanremo.Repo.Migrations.CreatePerformanceTypes do
  use Ecto.Migration

  def change do
    create table(:performance_types) do
      add :type, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:performance_types, [:type])
  end
end
