defmodule VotaSanremo.Repo.Migrations.CreatePerformancetypes do
  use Ecto.Migration

  def change do
    create table(:performancetypes) do
      add :type, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:performancetypes, [:type])
  end
end
