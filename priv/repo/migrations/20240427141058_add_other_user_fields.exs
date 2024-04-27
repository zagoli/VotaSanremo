defmodule VotaSanremo.Repo.Migrations.AddOtherUserFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_type, :string, default: "user"
      add :first_name, :string
      add :last_name, :string
      add :username, :string, null: false
      add :default_vote_multiplier, :float, default: 1.0
      add :votes_privacy, :string, default: "public"
    end

    create unique_index(:users, [:username])
  end
end
