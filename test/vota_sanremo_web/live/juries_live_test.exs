defmodule VotaSanremoWeb.JuriesLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "Logged user" do
    setup [:register_and_log_in_user]

    test "Should see the link to my juries", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/juries")
      assert html =~ "My Juries"
    end
  end

  describe "Guest user" do
    test "Should not see the link to my juries", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/juries")
      refute html =~ "My Juries"
    end
  end
end
