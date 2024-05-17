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

  describe "Evening selector" do
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
  end

  describe "Performances container" do
    setup [:create_edition, :register_and_log_in_user]

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

    test "Clicking on a vote when it is possible to vote navigates", %{
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

    test "Clicking on a vote when it isn't possible to vote does not navigate", %{
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

  describe "Vote form" do
    setup [:create_edition, :register_and_log_in_user]

    test "Navigating to add vote route shows modal when voting is permitted", %{
      conn: conn,
      edition: edition
    } do
      %{id: evening_id} =
        evening_fixture(%{
          edition_id: edition.id,
          votes_start: DateTime.utc_now() |> DateTime.add(-10, :minute),
          votes_end: DateTime.utc_now() |> DateTime.add(10, :minute)
        })

      %{id: performance_id} = performance_fixture(%{evening_id: evening_id})

      {:ok, live, _html} = live(conn, ~p"/vote/performance/#{performance_id}")
      assert live |> has_element?("#submit-vote-modal")
    end

    test "Cannot add vote when voting is prohibited",
         %{conn: conn, edition: edition} do
      %{id: evening_id} =
        evening_fixture(%{
          edition_id: edition.id,
          votes_start: DateTime.utc_now() |> DateTime.add(-10, :minute),
          votes_end: DateTime.utc_now() |> DateTime.add(2, :second)
        })

      %{id: performance_id} = performance_fixture(%{evening_id: evening_id})

      {:ok, live, _html} = live(conn, ~p"/vote/performance/#{performance_id}")

      Process.sleep(2000)

      live
      |> form("#vote-form")
      |> render_change(%{"score" => "5.25"})

      assert render(live) =~ "You cannot vote now."
      path = assert_patch(live)
      {:ok, _live, html} = live(conn, path)

      assert not (html =~ "5+")
    end

    test "Submitting a new vote for a performace creates a new vote",
         %{
           conn: conn,
           edition: edition
         } do
      %{id: evening_id} =
        evening_fixture(%{
          edition_id: edition.id,
          votes_start: DateTime.utc_now() |> DateTime.add(-10, :minute),
          votes_end: DateTime.utc_now() |> DateTime.add(10, :minute)
        })

      %{id: performance_id} = performance_fixture(%{evening_id: evening_id})

      {:ok, live, _html} = live(conn, ~p"/vote/performance/#{performance_id}")

      live
      |> form("#vote-form")
      |> render_change(%{"score" => "5.25"})

      assert render(live) =~ "Vote submitted!"
      path = assert_patch(live)
      {:ok, _live, html} = live(conn, path)

      assert html =~ "5+"
    end

    test "Updating a vote for a performace updates the vote",
         %{
           conn: conn,
           edition: edition,
           user: user
         } do
      %{id: evening_id} =
        evening_fixture(%{
          edition_id: edition.id,
          votes_start: DateTime.utc_now() |> DateTime.add(-10, :minute),
          votes_end: DateTime.utc_now() |> DateTime.add(10, :minute)
        })

      %{id: performance_id} = performance_fixture(%{evening_id: evening_id})
      vote_fixture(%{score: 1.0, performance_id: performance_id, user_id: user.id})

      {:ok, live, _html} = live(conn, ~p"/vote/performance/#{performance_id}")

      live
      |> form("#vote-form")
      |> render_change(%{"score" => "5.25"})

      assert render(live) =~ "Vote submitted!"
      path = assert_patch(live)
      {:ok, _live, html} = live(conn, path)
      assert html =~ "5+"
    end
  end
end
