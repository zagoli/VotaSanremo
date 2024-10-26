defmodule VotaSanremoWeb.ManageEditionsLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias VotaSanremo.Editions

  defp setup_editions(_) do
    %{editions: Editions.list_editions_with_evenings()}
  end

  describe "Manage editions" do
    setup [:register_and_log_in_admin, :setup_editions]

    test "The page contains the current editions", %{conn: conn, editions: editions} do
      {:ok, _live, html} = live(conn, ~p"/admin/editions")

      Enum.each(editions, fn edition ->
        assert html =~ edition.name
        assert html =~ edition.start_date
        assert html =~ edition.end_date
      end)
    end
  end
end
