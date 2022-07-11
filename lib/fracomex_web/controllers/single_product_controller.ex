defmodule FracomexWeb.SingleProductController do
  use FracomexWeb, :controller

  def index(conn, _params) do
    render(conn, "single_product.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end
end
