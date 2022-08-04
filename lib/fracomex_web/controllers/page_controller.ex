defmodule FracomexWeb.PageController do
  use FracomexWeb, :controller

  alias Fracomex.Products
  alias Fracomex.Utilities

  # Function de recherche
  def search(conn, params) do
    q =
      cond do
        params["q"] == %{} ->
          nil

        Utilities.is_empty?(params["q"]) ->
          nil

        true ->
          params["q"]
      end

    search =
      case q do
        nil ->
          nil
        _ ->
          Products.search_item(q)
      end

    if search != [] and not is_nil(search) do
      conn
      |> redirect(to: Routes.product_path(conn, :index, q: q))
    else
      conn
      |> redirect(to: Routes.product_path(conn, :index))
    end
  end

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      items: Products.list_items_arrival(),
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
