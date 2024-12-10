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
  end

  describe "jury_invitations" do
    alias VotaSanremo.Juries.JuryInvitation
    import VotaSanremo.{JuriesFixtures, AccountsFixtures}

    setup _ do
      %{user: user_fixture(), jury: jury_fixture()}
    end

    @invalid_attrs %{status: nil}

    test "list_jury_invitations/0 returns all jury_invitations" do
      jury_invitation = jury_invitation_fixture()
      assert Juries.list_jury_invitations() == [jury_invitation]
    end

    test "get_jury_invitation!/1 returns the jury_invitation with given id" do
      jury_invitation = jury_invitation_fixture()
      assert Juries.get_jury_invitation!(jury_invitation.id) == jury_invitation
    end

    test "create_jury_invitation/1 with valid data creates a jury_invitation", %{
      user: user,
      jury: jury
    } do
      valid_attrs = %{status: :accepted, user_id: user.id, jury_id: jury.id}

      assert {:ok, %JuryInvitation{} = jury_invitation} =
               Juries.create_jury_invitation(valid_attrs)

      assert jury_invitation.status == :accepted
    end

    test "create_jury_invitation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Juries.create_jury_invitation(@invalid_attrs)
    end

    test "update_jury_invitation/2 with valid data updates the jury_invitation" do
      jury_invitation = jury_invitation_fixture()
      update_attrs = %{status: :declined}

      assert {:ok, %JuryInvitation{} = jury_invitation} =
               Juries.update_jury_invitation(jury_invitation, update_attrs)

      assert jury_invitation.status == :declined
    end

    test "update_jury_invitation/2 with invalid data returns error changeset" do
      jury_invitation = jury_invitation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Juries.update_jury_invitation(jury_invitation, @invalid_attrs)

      assert jury_invitation == Juries.get_jury_invitation!(jury_invitation.id)
    end

    test "delete_jury_invitation/1 deletes the jury_invitation" do
      jury_invitation = jury_invitation_fixture()
      assert {:ok, %JuryInvitation{}} = Juries.delete_jury_invitation(jury_invitation)
      assert_raise Ecto.NoResultsError, fn -> Juries.get_jury_invitation!(jury_invitation.id) end
    end

    test "change_jury_invitation/1 returns a jury_invitation changeset" do
      jury_invitation = jury_invitation_fixture()
      assert %Ecto.Changeset{} = Juries.change_jury_invitation(jury_invitation)
    end

    test "validates unique contraints on user and jury", %{user: user, jury: jury} do
      jury_invitation_fixture(%{user_id: user.id, jury_id: jury.id})

      assert {:error, changeset} =
               Juries.create_jury_invitation(%{
                 user_id: user.id,
                 jury_id: jury.id,
                 status: :accepted
               })

      assert "has already been taken" in errors_on(changeset).jury_id
    end

    test "list_jury_pending_invitations/1 returns pending invitations for a jury", %{
      user: user,
      jury: jury
    } do
      pending_invitation =
        jury_invitation_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      # Create an accepted invitation that shouldn't be returned
      jury_invitation_fixture(%{
        jury_id: jury.id,
        status: :accepted
      })

      [invitation] = Juries.list_jury_pending_invitations(jury)
      assert invitation.id == pending_invitation.id
      assert invitation.user.first_name == user.first_name
    end

    test "list_user_pending_invitations/1 returns pending invitations for a user", %{
      user: user,
      jury: jury
    } do
      pending_invitation =
        jury_invitation_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      # Create an accepted invitation that shouldn't be returned
      jury_invitation_fixture(%{
        user_id: user.id,
        status: :accepted
      })

      [invitation] = Juries.list_user_pending_invitations(user)
      assert invitation.id == pending_invitation.id
      assert invitation.jury.name == jury.name
    end

    test "accept_invitation/1 accepts the invitation and adds user to jury", %{
      user: user,
      jury: jury
    } do
      invitation =
        jury_invitation_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      assert {:ok, accepted_invitation} = Juries.accept_invitation(invitation)
      assert accepted_invitation.status == :accepted

      # Use existing function to check user's juries
      user_juries = Juries.list_member_juries(user)
      assert Enum.any?(user_juries, fn j -> j.id == jury.id end)
    end

    test "decline_invitation/1 declines the invitation", %{user: user, jury: jury} do
      invitation =
        jury_invitation_fixture(%{
          user_id: user.id,
          jury_id: jury.id,
          status: :pending
        })

      assert {:ok, declined_invitation} = Juries.decline_invitation(invitation)
      assert declined_invitation.status == :declined

      # Use existing function to check user's juries
      user_juries = Juries.list_member_juries(user)
      refute Enum.any?(user_juries, fn j -> j.id == jury.id end)
    end
  end
end
