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
      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      performance_type = Performances.get_performance_type!(performance.performance_type_id)
      performer = Performers.get_performer!(performance.performer_id)

      assert has_element?(live, "#performance-#{performance.id}", performance_type.type)
      assert has_element?(live, "#performance-#{performance.id}", performer.name)
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
      render_submit(form)

      assert has_element?(live, "#performances", performer.name)
      assert has_element?(live, "#performances", performance_type.type)
    end

    test "It is possible to delete a performance", %{conn: conn, evening: evening} do
      performance = performance_fixture(%{evening_id: evening.id})
      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      live
      |> element("#performance-#{performance.id} button[title='delete performance']")
      |> render_click()

      assert has_element?(live, "[role='alert']", "Performance deleted successfully.")
      refute has_element?(live, "#performance-#{performance.id}")
    end
  end

  describe "Copy performances from another evening" do
    setup [:register_and_log_in_admin, :create_evening]

    test "The page shows the copy from evening form", %{conn: conn, evening: evening} do
      {:ok, _live, html} = live(conn, ~p"/admin/evening/#{evening.id}")

      assert html =~ "Copy from evening"
      assert html =~ "Select an evening"
    end

    test "It is possible to copy performances from another evening", %{
      conn: conn,
      evening: evening
    } do
      edition = edition_fixture()
      source_evening = evening_fixture(%{edition_id: edition.id, number: 3, date: ~D[2024-02-16]})
      performer = performer_fixture()
      performance_type = performance_type_fixture()

      performance_fixture(%{
        evening_id: source_evening.id,
        performer_id: performer.id,
        performance_type_id: performance_type.id
      })

      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      # Submit the copy form to open the confirmation modal
      live
      |> form("#copy-performances-form", copy_evening: %{evening_id: source_evening.id})
      |> render_submit()

      # Confirm the copy
      assert has_element?(live, "#confirm-copy-modal")

      live
      |> element("#confirm-copy-modal button", "Confirm")
      |> render_click()

      # The performances should have been copied
      assert has_element?(live, "#performances", performer.name)
      assert has_element?(live, "#performances", performance_type.type)
      assert has_element?(live, "[role='alert']", "Performances copied successfully.")
    end

    test "Copying performances deletes existing ones", %{conn: conn, evening: evening} do
      edition = edition_fixture()
      source_evening = evening_fixture(%{edition_id: edition.id, number: 3, date: ~D[2024-02-16]})

      # Create an existing performance in the target evening
      existing_perf = performance_fixture(%{evening_id: evening.id})

      existing_performer =
        VotaSanremo.Performers.get_performer!(existing_perf.performer_id)

      # Create a performance in the source evening
      new_performer = performer_fixture()

      performance_fixture(%{
        evening_id: source_evening.id,
        performer_id: new_performer.id
      })

      {:ok, live, _html} = live(conn, ~p"/admin/evening/#{evening.id}")

      # Verify existing performance is shown
      assert has_element?(live, "#performances", existing_performer.name)

      # Submit the copy form
      live
      |> form("#copy-performances-form", copy_evening: %{evening_id: source_evening.id})
      |> render_submit()

      # Confirm the copy
      live
      |> element("#confirm-copy-modal button", "Confirm")
      |> render_click()

      # The old performance should be gone, the new one should be there
      refute has_element?(live, "#performances", existing_performer.name)
      assert has_element?(live, "#performances", new_performer.name)
    end
  end
end
