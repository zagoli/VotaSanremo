defmodule VotaSanremoWeb.ManageEveningsLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.EveningsFixtures
  import VotaSanremo.EditionsFixtures
  import VotaSanremo.PerformancesFixtures
  import VotaSanremo.PerformersFixtures

  defp create_evening(_) do
    edition = edition_fixture()
    evening = evening_fixture(%{edition_id: edition.id, number: 1, date: ~D[2024-02-14]})
    # Create another evening in the same edition for uniqueness testing
    evening_fixture(%{edition_id: edition.id, number: 2, date: ~D[2024-02-15]})
    %{evening: evening}
  end

  describe "Edit evening" do
    setup [:register_and_log_in_admin, :create_evening]

    test "It is possible to edit an evening", %{conn: conn, evening: evening} do
      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      attrs = %{
        number: 3,
        description: "A new description",
        date: ~D[2024-02-15],
        votes_start: ~U[2024-02-15 20:00:00Z],
        votes_end: ~U[2024-02-15 23:59:59Z]
      }

      form = form(live, "#evening-form-#{evening.id}", evening: attrs)
      html = render_submit(form)

      assert html =~ "A new description"
      assert html =~ "2024-02-15"
    end

    test "It validates the evening when updating", %{conn: conn, evening: evening} do
      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      # Try to update to number 2, which is already taken
      attrs = %{number: 2}
      form = form(live, "#evening-form-#{evening.id}", evening: attrs)
      html = render_submit(form)

      assert html =~ "has already been taken"
    end
  end

  describe "Manage performances" do
    alias VotaSanremo.Performances
    alias VotaSanremo.Performers

    setup [:register_and_log_in_admin, :create_evening]

    test "The page displays a message if there are no performances", %{
      conn: conn,
      evening: evening
    } do
      {:ok, _live, html} = live(conn, ~p"/admin/evening/#{evening.id}")

      assert html =~ "There are no performances yet."
    end

    test "The page renders the performanes of the evening", %{conn: conn, evening: evening} do
      performance = performance_fixture(%{evening_id: evening.id})
      {:ok, _live, html} = live(conn, ~p"/admin/evening/#{evening.id}")

      performance_type = Performances.get_performance_type!(performance.performance_type_id)
      performer = Performers.get_performer!(performance.performer_id)

      performance_html =
        Floki.find(html, "#performance-#{performance.id}") |> List.first() |> Floki.text()

      assert performance_html =~ performance_type.type
      assert performance_html =~ performer.name
    end

    test "It is possible to add a performance", %{conn: conn, evening: evening} do
      performer = performer_fixture()
      performance_type = performance_type_fixture()

      attrs = %{
        performance_type_id: performance_type.id,
        performer_id: performer.id
      }

      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      form = form(live, "#add-performance", performance: attrs)
      html = render_submit(form)

      assert html =~ "Performance added successfully."
      performance_html = Floki.find(html, "#performances div") |> List.first() |> Floki.text()
      assert performance_html =~ performer.name
      assert performance_html =~ performance_type.type
    end

    test "It is possible to delete a performance", %{conn: conn, evening: evening} do
      performance = performance_fixture(%{evening_id: evening.id})
      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      html =
        live
        |> element("#performance-#{performance.id} button[title='delete performance']")
        |> render_click()

      performance_html = Floki.find(html, "#performance-#{performance.id}") |> List.first()

      assert html =~ "Performance deleted successfully."
      assert performance_html == nil
    end
  end
end
