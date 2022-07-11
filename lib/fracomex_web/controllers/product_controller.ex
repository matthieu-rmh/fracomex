defmodule FracomexWeb.ProductController do
  use FracomexWeb, :controller

  def index(conn, _params) do
    render(conn, "product.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end
end
