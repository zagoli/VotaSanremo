defmodule VotaSanremoWeb.ManageEditionsLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.EditionsFixtures
  import VotaSanremo.EveningsFixtures
  alias VotaSanremo.Editions

  defp setup_editions(_) do
    %{id: edition_1_id} = edition_fixture()
    %{id: edition_2_id} = edition_fixture()
    evening_fixture(%{edition_id: edition_1_id, number: 1, date: ~D[2034-04-09]})
    evening_fixture(%{edition_id: edition_1_id, number: 2, date: ~D[2034-04-10]})
    evening_fixture(%{edition_id: edition_2_id, number: 1, date: ~D[2034-04-11]})
    %{editions: Editions.list_editions_with_evenings()}
  end

  describe "Manage editions" do
    setup [:register_and_log_in_admin, :setup_editions]

    test "The page contains the current editions", %{conn: conn, editions: editions} do
      {:ok, _live, html} = live(conn, ~p"/admin/editions")

      Enum.each(editions, fn edition ->
        assert html =~ edition.name
        assert html =~ Date.to_string(edition.start_date)
        assert html =~ Date.to_string(edition.end_date)
      end)
    end

    test "Every edition has a list of evenings", %{conn: conn, editions: editions} do
      {:ok, _live, html} = live(conn, ~p"/admin/editions")
      {:ok, document} = Floki.parse_document(html)

      Enum.each(editions, fn edition ->
        evenings_div =
          Floki.find(document, "#edition-#{edition.id}-editor .evenings")
          |> Floki.text()

        Enum.each(edition.evenings, fn evening ->
          assert evenings_div =~ "#{evening.number}"
          assert evenings_div =~ Calendar.strftime(evening.date, "%d/%m/%Y")
          assert evenings_div =~ Calendar.strftime(evening.votes_start, "%d/%m/%Y")
          assert evenings_div =~ Calendar.strftime(evening.votes_end, "%d/%m/%Y")
        end)
      end)
    end

    test "It is possible to edit an edition name", %{conn: conn, editions: [edition | _]} do
      {:ok, live, _html} = live(conn, ~p"/admin/editions")
      new_name = "New name"

      form(live, "#edition-#{edition.id}-editor form", edition: %{name: new_name})
      |> render_submit()

      # The parent updates and then we check
      assert render(live) =~ new_name
    end

    test "It is possible to edit an edition start and end date", %{
      conn: conn,
      editions: [edition | _]
    } do
      {:ok, live, _html} = live(conn, ~p"/admin/editions")

      # Start date
      new_start_date = ~D[2024-04-01]

      form(live, "#edition-#{edition.id}-editor form", edition: %{start_date: new_start_date})
      |> render_submit()

      assert render(live) =~ Date.to_string(new_start_date)

      # End date
      new_end_date = ~D[2024-04-30]

      form(live, "#edition-#{edition.id}-editor form", edition: %{end_date: new_end_date})
      |> render_submit()

      assert render(live) =~ Date.to_string(new_end_date)
    end
  end
end
