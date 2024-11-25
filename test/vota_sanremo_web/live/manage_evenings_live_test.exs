defmodule VotaSanremoWeb.ManageEveningsLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.EveningsFixtures
  import VotaSanremo.EditionsFixtures

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
end
