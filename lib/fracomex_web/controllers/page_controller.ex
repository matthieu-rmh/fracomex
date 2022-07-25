defmodule FracomexWeb.PageController do
  use FracomexWeb, :controller

  alias Fracomex.Products

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      layout: {FracomexWeb.LayoutView, "layout.html"},
      items: Products.list_items(),
      families: Products.list_families(),
      sub_families: Products.list_sub_families(),
      cart: Plug.Conn.get_session(conn, :cart)
    )

    # render(conn, "arrivage.html")
  end

end
