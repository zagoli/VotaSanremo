defmodule VotaSanremoWeb.NewJuryLiveTest do
  use VotaSanremoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "New Jury" do
    setup [:register_and_log_in_user]

    test "create jury redirects on success", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/juries/new")

      form(live, "#create-jury-form", jury: %{name: "test"})
      |> render_submit()

      {path, _} = assert_redirect(live)
      assert path =~ ~r/juries\/\d+/
    end
  end
end
