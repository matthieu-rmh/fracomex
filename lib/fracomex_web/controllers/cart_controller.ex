defmodule FracomexWeb.CartController do
  use FracomexWeb, :controller

  def index(conn, _params) do
    render(conn, "cart.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end
end
