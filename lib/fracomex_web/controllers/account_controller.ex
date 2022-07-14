defmodule FracomexWeb.AccountController do
  use FracomexWeb, :controller

  def index(conn, _params) do
    render(conn, "my_account.html.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  #page mon compte
  def my_account(conn, _params) do
    render(conn, "my_account.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  #page adresse
  def address(conn, _params) do
    render(conn, "my_address.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end

end
