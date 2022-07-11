defmodule FracomexWeb.UsersController do
  use FracomexWeb, :controller

  def index(conn, _params) do
    render(conn, "connexion.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end
  def signin(conn, _params) do
    render(conn, "inscription.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end
end
