defmodule FracomexWeb.ProductController do
  use FracomexWeb, :controller

  def index(conn, _params) do
    IO.inspect(get_session(conn, :user_id))
    render(conn, "product.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end
end
