defmodule FracomexWeb.PageController do
  use FracomexWeb, :controller

  alias Fracomex.Products

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      layout: {FracomexWeb.LayoutView, "layout.html"},
      items: Products.list_items(),
      item_families: Products.list_families(),
      item_sub_families: Products.list_sub_families()
    )
    # render(conn, "arrivage.html")
  end

end
