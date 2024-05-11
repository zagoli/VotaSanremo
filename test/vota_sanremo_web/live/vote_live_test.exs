defmodule VotaSanremoWeb.VoteLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import VotaSanremo.EditionsFixtures
  import VotaSanremo.EveningsFixtures

  defp create_edition(_) do
    %{edition: edition_fixture()}
  end

  describe "Vote" do
    setup [:create_edition, :register_and_log_in_user]

    test "Evening selector creates evenings button", %{conn: conn, edition: edition} do
      evening_fixture(%{
        number: 1,
        date: ~D[2024-01-01],
        description: "First",
        edition_id: edition.id
      })

      evening_fixture(%{
        number: 2,
        date: ~D[2024-01-02],
        description: "Second",
        edition_id: edition.id
      })

      {:ok, live, _html} = live(conn, ~p"/vote")

      assert live |> element("button", "1") |> has_element?()
      assert live |> element("button", "2") |> has_element?()
    end

    test "Evening selector changes evening", %{conn: conn, edition: edition} do
      evening_fixture(%{
        number: 1,
        date: ~D[2024-01-01],
        description: "First",
        edition_id: edition.id
      })

      evening_fixture(%{
        number: 2,
        date: ~D[2024-01-02],
        description: "Second",
        edition_id: edition.id
      })

      {:ok, live, html} = live(conn, ~p"/vote")

      assert html =~ "First"
      assert live |> element("button", "2") |> render_click() =~ "Second"
    end

    test "Default evening of today's evening is selected if present", %{
      conn: conn,
      edition: edition
    } do
      evening_fixture(%{
        number: 1,
        date: ~D[2024-01-01],
        description: "Another evening",
        edition_id: edition.id
      })

      evening_fixture(%{
        number: 2,
        date: DateTime.utc_now() |> DateTime.to_date(),
        description: "This evening",
        edition_id: edition.id
      })

      {:ok, _live, html} = live(conn, ~p"/vote")
      assert html =~ "This evening"
    end

    test "Default evening of first evening is selected if today's evening is not present", %{
      conn: conn,
      edition: edition
    } do
      evening_fixture(%{
        number: 5,
        date: ~D[2024-01-01],
        description: "Fifth evening",
        edition_id: edition.id
      })

      evening_fixture(%{
        number: 1,
        date: ~D[2022-01-01],
        description: "First evening",
        edition_id: edition.id
      })

      {:ok, _live, html} = live(conn, ~p"/vote")
      assert html =~ "First evening"
    end

    test "Navigating to add new vote route shows modal", %{conn: conn, edition: edition} do
      evening_fixture(%{edition_id: edition.id})
      {:ok, _live, html} = live(conn, ~p"/vote/performance/1")
      assert html =~ "id=\"submit-vote-modal\""
    end
  end
end
