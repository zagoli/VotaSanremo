defmodule VotaSanremo.JuriesTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Juries

  describe "juries" do
    alias VotaSanremo.Juries.Jury
    import VotaSanremo.{JuriesFixtures, AccountsFixtures}

    @invalid_attrs %{name: nil, founder: -1}

    test "list_juries/0 returns all juries" do
      jury = jury_fixture()
      assert Juries.list_juries() == [jury]
    end

    test "list_top_juries/0 returns the ten juries with most members" do
      juries = for n <- 15..1//-1, do: %{jury: create_jury_with_n_members(n), member_count: n}

      top_juries = Juries.list_top_juries()
      assert Enum.count(top_juries) == 10
      assert top_juries == Enum.take(juries, 10)
    end

    test "get_jury!/1 returns the jury with given id" do
      jury = jury_fixture()
      assert Juries.get_jury!(jury.id) == jury
    end

    test "get_jury/1 returns the jury with given id" do
      jury = jury_fixture()
      assert Juries.get_jury(jury.id) == jury
    end

    test "get_jury/1 returns nil if the id is not present" do
      assert Juries.get_jury(1) == nil
    end

    test "create_jury/1 with valid data creates a jury" do
      %{id: user_id} = user_fixture()
      valid_attrs = %{name: "someName", founder: user_id}

      assert {:ok, %Jury{} = jury} = Juries.create_jury(valid_attrs)
      assert jury.name == "someName"
      assert jury.founder == user_id
    end

    test "create_jury/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Juries.create_jury(@invalid_attrs)
    end

    test "update_jury/2 with valid data updates the jury" do
      jury = jury_fixture()
      update_attrs = %{name: "someUpdatedName"}

      assert {:ok, %Jury{} = jury} = Juries.update_jury(jury, update_attrs)
      assert jury.name == "someUpdatedName"
    end

    test "update_jury/2 with invalid data returns error changeset" do
      jury = jury_fixture()
      assert {:error, %Ecto.Changeset{}} = Juries.update_jury(jury, @invalid_attrs)
      assert jury == Juries.get_jury!(jury.id)
    end

    test "delete_jury/1 deletes the jury" do
      jury = jury_fixture()
      assert {:ok, %Jury{}} = Juries.delete_jury(jury)
      assert_raise Ecto.NoResultsError, fn -> Juries.get_jury!(jury.id) end
    end

    test "change_jury/1 returns a jury changeset" do
      jury = jury_fixture()
      assert %Ecto.Changeset{} = Juries.change_jury(jury)
    end

    test "get_jury_with_members/1 returns the jury with preloaded members" do
      jury = jury_fixture()
      user = user_fixture()
      assert {:ok, _} = Juries.add_member(jury, user)

      loaded_jury = Juries.get_jury_with_members(jury.id)
      assert loaded_jury.id == jury.id
      assert [member] = loaded_jury.members
      assert member.id == user.id
    end

    test "member_exit/2 removes the member and deletes the jury invite" do
      jury = jury_fixture()
      member = user_fixture()
      jury_invite_fixture(%{jury_id: jury.id, user_id: member.id})
      Juries.add_member(jury, member)

      assert Juries.member_exit(jury, member) == :ok

      refute Juries.member?(jury, member)

      assert_raise Ecto.NoResultsError, fn ->
        Juries.get_jury_invite_by_jury_and_user!(jury, member)
      end
    end

    test "member?/2 returns true if the user is a member of the jury" do
      jury = jury_fixture()
      member = user_fixture()
      Juries.add_member(jury, member)

      assert Juries.member?(jury, member)
    end

    test "member?/2 returns false if the user is not a member of the jury" do
      jury = jury_fixture()
      user = user_fixture()

      refute Juries.member?(jury, user)
    end

    defp create_jury_with_n_members(n) when is_integer(n) do
      jury = jury_fixture()

      Enum.each(1..n, fn _ ->
        user = user_fixture()
        Juries.add_member(jury, user)
      end)

      jury
    end
  end

  describe "jury_invites" do
    alias VotaSanremo.Juries.JuryInvite
    import VotaSanremo.{JuriesFixtures, AccountsFixtures}

    setup _ do
      %{user: user_fixture(), jury: jury_fixture()}
    end

    @invalid_attrs %{status: nil}

    test "list_jury_invites/0 returns all jury_invites" do
      jury_invite = jury_invite_fixture()
      assert Juries.list_jury_invites() == [jury_invite]
    end

    test "get_jury_invite!/1 returns the jury_invite with given id" do
      jury_invite = jury_invite_fixture()
      assert Juries.get_jury_invite!(jury_invite.id) == jury_invite
    end

    test "get_jury_invite_by_jury_and_user!/2 returns the jury_invite with given user and jury" do
      jury = jury_fixture()
      user = user_fixture()
      jury_invite = jury_invite_fixture(%{jury_id: jury.id, user_id: user.id})
      assert Juries.get_jury_invite_by_jury_and_user!(jury, user) == jury_invite
    end

    test "create_jury_invite/1 with valid data creates a jury_invite", %{
      user: user,
      jury: jury
    } do
      valid_attrs = %{status: :accepted, user_id: user.id, jury_id: jury.id}

      assert {:ok, %JuryInvite{} = jury_invite} =
               Juries.create_jury_invite(valid_attrs)

      assert jury_invite.status == :accepted
    end

    test "create_jury_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Juries.create_jury_invite(@invalid_attrs)
    end

    test "update_jury_invite/2 with valid data updates the jury_invite" do
      jury_invite = jury_invite_fixture()
      update_attrs = %{status: :declined}

      assert {:ok, %JuryInvite{} = jury_invite} =
               Juries.update_jury_invite(jury_invite, update_attrs)

      assert jury_invite.status == :declined
    end

    test "update_jury_invite/2 with invalid data returns error changeset" do
      jury_invite = jury_invite_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Juries.update_jury_invite(jury_invite, @invalid_attrs)

      assert jury_invite == Juries.get_jury_invite!(jury_invite.id)
    end

    test "delete_jury_invite/1 deletes the jury_invite" do
      jury_invite = jury_invite_fixture()
      assert {:ok, %JuryInvite{}} = Juries.delete_jury_invite(jury_invite)
      assert_raise Ecto.NoResultsError, fn -> Juries.get_jury_invite!(jury_invite.id) end
    end

    test "change_jury_invite/1 returns a jury_invite changeset" do
      jury_invite = jury_invite_fixture()
      assert %Ecto.Changeset{} = Juries.change_jury_invite(jury_invite)
    end

    test "validates unique contraints on user and jury", %{user: user, jury: jury} do
      jury_invite_fixture(%{user_id: user.id, jury_id: jury.id})

      assert {:error, changeset} =
               Juries.create_jury_invite(%{
                 user_id: user.id,
                 jury_id: jury.id,
                 status: :accepted
               })

      assert "has already been taken" in errors_on(changeset).jury_id
    end

    test "list_jury_pending_invites/1 returns pending invites for a jury", %{
      user: user,
      jury: jury
    } do
      pending_invite =
        jury_invite_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      # Create an accepted invite that shouldn't be returned
      jury_invite_fixture(%{
        jury_id: jury.id,
        status: :accepted
      })

      [invite] = Juries.list_jury_pending_invites(jury)
      assert invite.id == pending_invite.id
      assert invite.user.first_name == user.first_name
    end

    test "list_user_pending_invites/1 returns pending invites for a user", %{
      user: user,
      jury: jury
    } do
      pending_invite =
        jury_invite_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      # Create an accepted invite that shouldn't be returned
      jury_invite_fixture(%{
        user_id: user.id,
        status: :accepted
      })

      [invite] = Juries.list_user_pending_invites(user)
      assert invite.id == pending_invite.id
      assert invite.jury.name == jury.name
    end

    test "accept_invite/1 accepts the invite and adds user to jury", %{
      user: user,
      jury: jury
    } do
      invite =
        jury_invite_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      assert {:ok, %{invite: accepted_invite}} = Juries.accept_invite(invite)
      assert accepted_invite.status == :accepted

      # Use existing function to check user's juries
      user_juries = Juries.list_member_juries(user)
      assert Enum.any?(user_juries, fn j -> j.id == jury.id end)
    end

    test "decline_invite/1 declines the invite", %{user: user, jury: jury} do
      invite =
        jury_invite_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      assert {:ok, declined_invite} = Juries.decline_invite(invite)
      assert declined_invite.status == :declined

      # Use existing function to check user's juries
      user_juries = Juries.list_member_juries(user)
      refute Enum.any?(user_juries, fn j -> j.id == jury.id end)
    end
  end
end
