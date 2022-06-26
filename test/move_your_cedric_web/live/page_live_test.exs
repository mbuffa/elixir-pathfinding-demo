defmodule MoveYourCedricWeb.PageLiveTest do
  use MoveYourCedricWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/placeholder")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(page_live) =~ "Welcome to Phoenix!"
  end
end
