defmodule VotaSanremo.Repo.Migrations.CreateJuryInvites do
  use Ecto.Migration

  def change do
    create table(:jury_invites) do
      add :status, :string, default: "pending"
      add :jury_id, references(:juries, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:jury_invites, [:jury_id, :user_id])
    create index(:jury_invites, [:jury_id])
    create index(:jury_invites, [:user_id])
  end
end
