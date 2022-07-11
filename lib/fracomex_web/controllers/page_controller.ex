defmodule FracomexWeb.PageController do
  use FracomexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", layout: {FracomexWeb.LayoutView, "layout.html"})
    # render(conn, "arrivage.html")
  end

end
