defmodule VotaSanremoWeb.ManagePerformanceTypesLiveTest do
  use VotaSanremoWeb.ConnCase

  import Phoenix.LiveViewTest
  import VotaSanremo.PerformancesFixtures

  @create_attrs %{type: "some type"}
  @update_attrs %{type: "some updated type"}
  @invalid_attrs %{type: nil}

  defp create_performance_type(_) do
    performance_type = performance_type_fixture()
    %{performance_type: performance_type}
  end

  describe "Manage performance types" do
    setup [:register_and_log_in_admin, :create_performance_type]

    test "lists all performance types", %{conn: conn, performance_type: performance_type} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/performance_types")

      assert html =~ "Performance types"
      assert html =~ performance_type.type
    end

    test "saves new performance type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/performance_types")

      assert index_live |> element("a", "+") |> render_click() =~
               "New performance type"

      assert_patch(index_live, ~p"/admin/performance_types/new")

      assert index_live
             |> form("#performance_type-form", performance_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#performance_type-form", performance_type: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/performance_types")

      html = render(index_live)
      assert html =~ "Performance type created"
      assert html =~ "some type"
    end

    test "updates performance type in listing", %{conn: conn, performance_type: performance_type} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/performance_types")

      assert index_live
             |> element("#performance_types-#{performance_type.id} a[aria-label='Edit']")
             |> render_click() =~
               "Edit performance type"

      assert_patch(index_live, ~p"/admin/performance_types/#{performance_type}/edit")

      assert index_live
             |> form("#performance_type-form", performance_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#performance_type-form", performance_type: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/performance_types")

      html = render(index_live)
      assert html =~ "Performance type updated"
      assert html =~ "some updated type"
    end

    test "deletes performance type in listing", %{conn: conn, performance_type: performance_type} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/performance_types")

      assert index_live
             |> element("#performance_types-#{performance_type.id} a[aria-label='Delete']")
             |> render_click()

      refute has_element?(index_live, "#performance_types-#{performance_type.id}")
    end
  end
end
