defmodule VotaSanremo.Repo.Migrations.CreateJuries do
  use Ecto.Migration

  def change do
    create table(:juries) do
      add :name, :string
      add :founder, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:juries, [:name])
    create index(:juries, [:founder])
  end
end
