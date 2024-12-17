defmodule VotaSanremo.Juries.JuriesComposition do
  use Ecto.Schema

  alias VotaSanremo.Accounts.User
  alias VotaSanremo.Juries.Jury

  @primary_key false
  schema "juries_composition" do
    belongs_to :user, User
    belongs_to :jury, Jury
  end
end
