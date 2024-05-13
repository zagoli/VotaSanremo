defmodule VotaSanremoWeb.VoteLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  import VotaSanremo.{
    EditionsFixtures,
    EveningsFixtures,
    PerformersFixtures,
    PerformancesFixtures,
    VotesFixtures
  }

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

    test "Navigating to new or edit vote route shows modal", %{conn: conn, edition: edition} do
      evening_fixture(%{edition_id: edition.id})
      {:ok, _live, html} = live(conn, ~p"/vote/performance/new/1")
      assert html =~ "submit-vote-modal"
      {:ok, _live, html} = live(conn, ~p"/vote/performance/edit/1")
      assert html =~ "submit-vote-modal"
    end

    test "Each performance of an evening is correctly rendered", %{
      conn: conn,
      edition: edition,
      user: user
    } do
      %{id: evening_id} = evening_fixture(%{edition_id: edition.id})
      %{id: first_performance_type_id} = performance_type_fixture(%{type: "Songs"})
      %{id: second_performance_type_id} = performance_type_fixture(%{type: "Dresses"})
      %{id: performer_id} = performer_fixture(%{name: "Johnny"})

      %{id: first_performance_id} =
        performance_fixture(%{
          evening_id: evening_id,
          performer_id: performer_id,
          performance_type_id: first_performance_type_id
        })

      performance_fixture(%{
        evening_id: evening_id,
        performer_id: performer_id,
        performance_type_id: second_performance_type_id
      })

      vote_fixture(%{score: 8, performance_id: first_performance_id, user_id: user.id})

      {:ok, _live, html} = live(conn, ~p"/vote")
      assert html =~ "Johnny"
      assert html =~ "8"
      assert html =~ "-"
      assert html =~ "Songs"
      assert html =~ "Dresses"
    end

    test "Clicking on a vote when it is possible to vote navigates to modal", %{
      conn: conn,
      edition: edition
    } do
      %{id: evening_id} =
        evening_fixture(%{
          edition_id: edition.id,
          votes_start: DateTime.utc_now() |> DateTime.add(-10, :minute),
          votes_end: DateTime.utc_now() |> DateTime.add(10, :minute)
        })

      performance_fixture(%{evening_id: evening_id})

      {:ok, live, _html} = live(conn, ~p"/vote")

      live
      |> element("button", "-")
      |> render_click()

      assert_patch(live)
    end

    test "Clicking on a vote when it isn't possible to vote do not navigate to modal", %{
      conn: conn,
      edition: edition
    } do
      %{id: evening_id} =
        evening_fixture(%{
          edition_id: edition.id,
          votes_start: DateTime.utc_now() |> DateTime.add(10, :minute)
        })

      performance_fixture(%{evening_id: evening_id})

      {:ok, live, _html} = live(conn, ~p"/vote")

      assert_raise ArgumentError, "cannot click element \"button\" because it is disabled", fn ->
        live
        |> element("button", "-")
        |> render_click()
      end
    end
  end
end
