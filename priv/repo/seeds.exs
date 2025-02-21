# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VotaSanremo.Repo.insert!(%VotaSanremo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias VotaSanremo.Juries
alias VotaSanremo.Accounts
alias VotaSanremo.Performances
alias VotaSanremo.Evenings
alias VotaSanremo.Editions
alias VotaSanremo.Performers
alias VotaSanremo.Votes

# Create users
users_attrs = [
  %{
    email: "gerry@example.com",
    password: "GerryTheBest99!",
    username: "ErGerry",
    first_name: "Geremia"
  },
  %{
    email: "sam@example.com",
    password: "SamTheBest99!",
    username: "ErSamuel",
    first_name: "Giovanni"
  }
]

Enum.each(users_attrs, fn attrs -> Accounts.register_user(attrs) end)

# Set user type as admin for ErGerry
gerry = Accounts.get_user_by_email("gerry@example.com")
Accounts.update_user_type(gerry, :admin)

# Confirm users
users = for user_attr <- users_attrs, do: Accounts.get_user_by_email(user_attr.email)

Enum.each(users, fn user ->
  VotaSanremo.Repo.transaction(VotaSanremo.Accounts.confirm_user_multi(user))
end)

# Create performance_types
performance_types_attrs = [
  %{type: "Songs"},
  %{type: "Dresses"}
]

Enum.each(performance_types_attrs, fn attrs -> Performances.create_performance_type(attrs) end)

# Create editions
editions_attr = [
  %{name: "First Festival Edition", start_date: ~D[2023-02-04], end_date: ~D[2023-02-08]}
]

Enum.each(editions_attr, fn attrs -> Editions.create_edition(attrs) end)

# Create evenings
[%{id: edition_id} | _] = Editions.list_editions()

evenings_attrs = [
  %{
    date: ~D[2023-02-04],
    description: "First evening",
    number: 1,
    votes_start: ~U[1970-01-01 00:00:01Z],
    votes_end: ~U[2900-01-01 00:00:01Z],
    edition_id: edition_id
  },
  %{
    date: ~D[2023-02-05],
    description: "Second evening",
    number: 2,
    votes_start: ~U[2023-02-05 20:00:00Z],
    votes_end: ~U[2023-02-06 01:00:00Z],
    edition_id: edition_id
  },
  %{
    date: ~D[2023-02-06],
    description: "Third evening",
    number: 3,
    votes_start: ~U[2023-02-06 19:30:00Z],
    votes_end: ~U[2023-02-07 00:30:00Z],
    edition_id: edition_id
  },
  %{
    date: ~D[2023-02-07],
    description: "Fourth evening",
    number: 4,
    votes_start: ~U[2023-02-07 21:00:00Z],
    votes_end: ~U[2023-02-08 02:30:00Z],
    edition_id: edition_id
  },
  %{
    date: ~D[2023-02-08],
    description: "Fifth evening",
    number: 5,
    votes_start: ~U[2023-02-08 19:00:00Z],
    votes_end: ~U[2023-02-09 00:30:00Z],
    edition_id: edition_id
  }
]

Enum.each(evenings_attrs, fn attrs -> Evenings.create_evening(attrs) end)

# Create performers
performers_attrs = [
  %{name: "Mina"},
  %{name: "Giorgio Gaber"},
  %{name: "Elio e le Storie Tese"}
]

Enum.each(performers_attrs, fn attrs -> Performers.create_performer(attrs) end)

# Create performances
[first_performance_type, second_performance_type | _] = Performances.list_performance_types()
[first_performer, second_performer, third_performer | _] = Performers.list_performers()
[first_evening, second_evening | _] = Evenings.list_evenings()

performances_attrs = [
  %{
    performance_type_id: first_performance_type.id,
    evening_id: first_evening.id,
    performer_id: first_performer.id
  },
  %{
    performance_type_id: first_performance_type.id,
    evening_id: first_evening.id,
    performer_id: second_performer.id
  },
  %{
    performance_type_id: first_performance_type.id,
    evening_id: first_evening.id,
    performer_id: third_performer.id
  },
  %{
    performance_type_id: second_performance_type.id,
    evening_id: first_evening.id,
    performer_id: first_performer.id
  },
  %{
    performance_type_id: first_performance_type.id,
    evening_id: second_evening.id,
    performer_id: first_performer.id
  },
  %{
    performance_type_id: first_performance_type.id,
    evening_id: second_evening.id,
    performer_id: second_performer.id
  },
  %{
    performance_type_id: first_performance_type.id,
    evening_id: second_evening.id,
    performer_id: third_performer.id
  }
]

Enum.each(performances_attrs, fn attrs -> Performances.create_performance(attrs) end)

# Create votes
[first_performance, second_performance | _] = Performances.list_performances()
%{id: gerry_id} = Accounts.get_user_by_email("gerry@example.com")

votes_attrs = [
  %{score: 5.25, multiplier: 1.0, user_id: gerry_id, performance_id: first_performance.id},
  %{score: 8.5, multiplier: 1.0, user_id: gerry_id, performance_id: second_performance.id}
]

Enum.each(votes_attrs, fn attrs -> Votes.create_vote(attrs) end)

# Create juries
%{id: sam_id} = Accounts.get_user_by_email("sam@example.com")
{:ok, jury} = Juries.create_jury(%{name: "Sam's Jury", founder: sam_id})
Juries.add_member(jury, Accounts.get_user!(gerry_id))
