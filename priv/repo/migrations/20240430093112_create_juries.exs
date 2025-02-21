defmodule VotaSanremo.Repo.Migrations.CreateJuries do
  use Ecto.Migration

  def change do
    create table(:juries) do
      add :name, :string, null: false
      add :founder, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:juries, [:name])
    create index(:juries, [:founder])
  end
end
