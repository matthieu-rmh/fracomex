defmodule FracomexWeb.PageController do
  use FracomexWeb, :controller

  alias Fracomex.Products

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      items: Products.list_items(),
      families: Products.list_families(),
      sub_families: Products.list_sub_families(),
      cart: Plug.Conn.get_session(conn, :cart),
      sum_cart: Plug.Conn.get_session(conn, :sum_cart)
    )

    # render(conn, "arrivage.html")
  end
  #contact page
  def contact(conn, _params) do
    render(
      conn,
      "contact.html",
      cart: Plug.Conn.get_session(conn, :cart),
      sum_cart: Plug.Conn.get_session(conn, :sum_cart)
    )
  end
end
