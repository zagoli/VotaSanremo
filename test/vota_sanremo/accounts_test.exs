defmodule VotaSanremo.AccountsTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Accounts

  import VotaSanremo.AccountsFixtures
  alias VotaSanremo.Accounts.{User, UserToken}

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "user default values" do
    test "user fields with defaults are populated correctly" do
      %{id: id} = user_fixture()
      user = Accounts.get_user!(id)
      assert user.user_type == :user
      assert user.default_vote_multiplier == 1.0
      assert user.votes_privacy == :public
    end
  end

  describe "register_user/1" do
    test "requires username, email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"],
               username: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: [
                 "at least one digit or punctuation character",
                 "at least one upper case character",
                 "should be at least 12 character(s)"
               ]
             } = errors_on(changeset)
    end

    test "validates votes privacy value is admissible" do
      {:error, changeset} = Accounts.register_user(%{votes_privacy: :restricted})
      assert %{votes_privacy: ["is invalid"]} = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates maximum values for first name, last name and username" do
      too_long = String.duplicate("a", 161)

      {:error, changeset} =
        Accounts.register_user(%{first_name: too_long, last_name: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).first_name
      assert "should be at most 160 character(s)" in errors_on(changeset).last_name
    end

    test "validates username format and length" do
      # Too long
      {:error, changeset} = Accounts.register_user(%{username: String.duplicate("a", 161)})
      assert "should be at most 160 character(s)" in errors_on(changeset).username

      # Too short
      {:error, changeset} = Accounts.register_user(%{username: "aaa"})
      assert "should be at least 4 character(s)" in errors_on(changeset).username

      # Invalid format
      {:error, changeset} = Accounts.register_user(%{username: "invalid-username"})
      assert "must contain only letters and numbers" in errors_on(changeset).username

      # Valid username
      {:error, changeset} = Accounts.register_user(%{username: "Perfectly00Valid00Username"})
      refute Map.has_key?(errors_on(changeset), :username)
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates username uniqueness" do
      %{username: username} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{username: username})
      assert "has already been taken" in errors_on(changeset).username
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email, :username]
    end

    test "allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()
      username = "Greg"
      first_name = "Gregory"
      last_name = "Big"
      default_vote_multiplier = 0.5
      votes_privacy = :private

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(
            email: email,
            password: password,
            first_name: first_name,
            last_name: last_name,
            username: username,
            default_vote_multiplier: default_vote_multiplier,
            votes_privacy: votes_privacy
          )
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert get_change(changeset, :first_name) == first_name
      assert get_change(changeset, :last_name) == last_name
      assert get_change(changeset, :username) == username
      assert get_change(changeset, :default_vote_multiplier) == default_vote_multiplier
      assert get_change(changeset, :votes_privacy) == votes_privacy
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_type/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_type(%User{})
      assert changeset.required == [:user_type]
    end

    test "allows user_type to be set" do
      user_type = :admin

      changeset = Accounts.change_user_type(%User{}, %{user_type: user_type})

      assert changeset.valid?
      assert get_change(changeset, :user_type) == user_type
    end

    test "validates user_type inclusion" do
      changeset = Accounts.change_user_type(%User{}, %{user_type: :invalid})

      assert ["is invalid"] = errors_on(changeset).user_type
    end
  end

  describe "update_user_type/2" do
    setup do
      %{user: user_fixture()}
    end

    test "updates the user type", %{user: user} do
      new_user_type = :admin
      {:ok, updated_user} = Accounts.update_user_type(user, new_user_type)
      assert updated_user.user_type == new_user_type
    end

    test "does not update with invalid user type", %{user: user} do
      {:error, changeset} = Accounts.update_user_type(user, :invalid)
      assert ["is invalid"] = errors_on(changeset).user_type
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: user_fixture()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      %{email: email} = user_fixture()
      password = valid_user_password()

      {:error, changeset} = Accounts.apply_user_email(user, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Accounts.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Accounts.get_user!(user.id).email != email
    end
  end

  describe "deliver_user_update_email_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = Accounts.change_user(%User{})
    end
  end

  describe "update_user/2" do
    setup do
      %{user: user_fixture(first_name: "name", last_name: "surname", votes_privacy: :public)}
    end

    test "updates the user", %{user: user} do
      new_first_name = "new name"
      new_last_name = "new surname"
      new_votes_privacy = :private

      {:ok, updated_user} =
        Accounts.update_user(user, %{
          first_name: new_first_name,
          last_name: new_last_name,
          votes_privacy: new_votes_privacy
        })

      assert updated_user.first_name == new_first_name
      assert updated_user.last_name == new_last_name
      assert updated_user.votes_privacy == new_votes_privacy
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      valid_password = "New valid password!"

      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => valid_password
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == valid_password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: [
                 "at least one digit or punctuation character",
                 "at least one upper case character",
                 "should be at least 12 character(s)"
               ],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "New valid password!"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "New valid password!")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "New valid password!"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_user_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: [
                 "at least one digit or punctuation character",
                 "at least one upper case character",
                 "should be at least 12 character(s)"
               ],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "New valid password!"})
      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "New valid password!")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "New valid password!"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "list_users_by_username/1" do
    alias VotaSanremo.UserSearch

    setup do
      user_fixture(%{username: "user1"})
      user_fixture(%{username: "user2"})
      user_fixture(%{username: "user3"})
      user_fixture(%{username: "user4"})
      user_fixture(%{username: "user5"})
      :ok
    end

    test "finds all users starting with the provided username" do
      changeset = UserSearch.change_username(%{"username" => "User"})

      found_usernames =
        Accounts.list_users_by_username(changeset)
        |> Enum.map(& &1.username)

      assert "user1" in found_usernames
      assert "user2" in found_usernames
      assert "user3" in found_usernames
      assert "user4" in found_usernames
      assert "user5" in found_usernames
    end

    test "find user with username containing text" do
      changeset = UserSearch.change_username(%{"username" => "1"})

      found_usernames =
        Accounts.list_users_by_username(changeset)
        |> Enum.map(& &1.username)

      assert "user1" in found_usernames
    end

    test "returns empty list when no match is found" do
      changeset = UserSearch.change_username(%{"username" => "nothing"})
      found_users = Accounts.list_users_by_username(changeset)
      assert Enum.empty?(found_users)
    end
  end

  describe "list_some_users/1" do
    setup do
      users = for _ <- 1..10, do: user_fixture()
      %{users: users}
    end

    test "returns the requested number of users" do
      assert Enum.count(Accounts.list_some_users(5)) == 5
      assert Enum.count(Accounts.list_some_users(3)) == 3
    end

    test "returns all users if requested number is greater than total users", %{users: users} do
      users_count = Enum.count(users)
      assert Enum.count(Accounts.list_some_users(users_count + 10)) == users_count
    end

    test "returns empty list if requested number is 0" do
      assert Accounts.list_some_users(0) == []
    end
  end

  defp create_users_for_counting(_) do
    user1 = user_fixture()
    user2 = user_fixture()
    user3 = user_fixture()
    admin = user_fixture()
    Accounts.update_user_type(admin, :admin)
    %{users: [user1, user2, user3]}
  end

  defp confirm_some_users(%{users: [user1, user2, _user3]} = context) do
    # Confirm two of the three users
    {:ok, _} = confirm_user(user1)
    {:ok, _} = confirm_user(user2)
    context
  end

  describe "count_users/0" do
    setup [:create_users_for_counting]

    test "returns total number of users with role user", %{users: users} do
      assert Accounts.count_users() == Enum.count(users)
    end
  end

  describe "count_confirmed_users/0" do
    setup [:create_users_for_counting, :confirm_some_users]

    test "returns number of confirmed users with role user" do
      assert Accounts.count_confirmed_users() == 2
    end
  end

  describe "delete_user/1" do
    import VotaSanremo.TestSetupFixtures, only: [setup_for_delete_user_test: 0]
    alias VotaSanremo.{Juries, Votes}
    alias VotaSanremo.Juries.Jury

    test "deletes the user" do
      {user, founded_jury, jury, invite, vote} = setup_for_delete_user_test()
      assert {:ok, %User{}} = Accounts.delete_user(user)

      assert %Jury{} = Juries.get_jury!(jury.id)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
      assert_raise Ecto.NoResultsError, fn -> Juries.get_jury!(founded_jury.id) end
      assert_raise Ecto.NoResultsError, fn -> Juries.get_jury_invite!(invite.id) end
      assert_raise Ecto.NoResultsError, fn -> Votes.get_vote!(vote.id) end
    end
  end
end
