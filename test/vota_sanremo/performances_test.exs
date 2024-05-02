defmodule VotaSanremo.PerformancesTest do
  use VotaSanremo.DataCase

  alias VotaSanremo.Performances

  describe "performancetypes" do
    alias VotaSanremo.Performances.PerformanceType

    import VotaSanremo.PerformancesFixtures

    @invalid_attrs %{type: nil}

    test "list_performancetypes/0 returns all performancetypes" do
      performance_type = performance_type_fixture()
      assert Performances.list_performancetypes() == [performance_type]
    end

    test "get_performance_type!/1 returns the performance_type with given id" do
      performance_type = performance_type_fixture()
      assert Performances.get_performance_type!(performance_type.id) == performance_type
    end

    test "create_performance_type/1 with valid data creates a performance_type" do
      valid_attrs = %{type: "some type"}

      assert {:ok, %PerformanceType{} = performance_type} = Performances.create_performance_type(valid_attrs)
      assert performance_type.type == "some type"
    end

    test "create_performance_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Performances.create_performance_type(@invalid_attrs)
    end

    test "update_performance_type/2 with valid data updates the performance_type" do
      performance_type = performance_type_fixture()
      update_attrs = %{type: "some updated type"}

      assert {:ok, %PerformanceType{} = performance_type} = Performances.update_performance_type(performance_type, update_attrs)
      assert performance_type.type == "some updated type"
    end

    test "update_performance_type/2 with invalid data returns error changeset" do
      performance_type = performance_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Performances.update_performance_type(performance_type, @invalid_attrs)
      assert performance_type == Performances.get_performance_type!(performance_type.id)
    end

    test "delete_performance_type/1 deletes the performance_type" do
      performance_type = performance_type_fixture()
      assert {:ok, %PerformanceType{}} = Performances.delete_performance_type(performance_type)
      assert_raise Ecto.NoResultsError, fn -> Performances.get_performance_type!(performance_type.id) end
    end

    test "change_performance_type/1 returns a performance_type changeset" do
      performance_type = performance_type_fixture()
      assert %Ecto.Changeset{} = Performances.change_performance_type(performance_type)
    end
  end
end
