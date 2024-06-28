defmodule VotaSanremo.Repo.Migrations.CreateJuryInvitations do
  use Ecto.Migration

  def change do
    create table(:jury_invitations) do
      add :status, :string, default: "pending"
      add :jury_id, references(:juries, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:jury_invitations, [:jury_id, :user_id])
    create index(:jury_invitations, [:jury_id])
    create index(:jury_invitations, [:user_id])
  end
end
