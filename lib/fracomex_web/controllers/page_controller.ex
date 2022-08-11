defmodule FracomexWeb.PageController do
  use FracomexWeb, :controller

  alias Fracomex.Products
  alias Fracomex.Utilities

  # Fonction ajout de produit dans le panier
  def add_to_cart(conn, params) do
    item = Products.get_item_with_family_and_sub_family!(params["id"])

    quantity = 1

    product_added_in_cart = "#{item.caption} a été ajouté au panier"

    cond do
      is_nil(conn.private[:plug_session]["cart"]) ->
        cart = %{
          product_id: item.id,
          quantity: quantity
        }

        conn
        |> put_session(:cart, [cart])
        |> put_session(:sum_cart, Utilities.sum_cart([cart]))
        |> put_flash(:info_panier, "(0#{quantity}) #{product_added_in_cart}")
        |> redirect(to: Routes.page_path(conn, :index, id: params["id"]))


      is_nil(Enum.find(conn.private[:plug_session]["cart"], fn cart -> cart.product_id == "#{item.id}" end)) ->
        cart = %{
          product_id: item.id,
          quantity: quantity
        }

        conn
        |> put_session(:cart, conn.private[:plug_session]["cart"] ++ [cart])
        |> put_session(:sum_cart, Utilities.sum_cart(conn.private[:plug_session]["cart"] ++ [cart]))
        |> put_flash(:info_panier, "(0#{quantity}) #{product_added_in_cart}")
        |> redirect(to: Routes.page_path(conn, :index, id: params["id"]))

      true ->

        # Retrouver la position de l'item dans le panier
        quantity_in_cart = Enum.find(conn.private[:plug_session]["cart"], &(&1.product_id == item.id)).quantity

        real_stock =
          Products.get_item!(item.id).real_stock
          |> Decimal.to_float()
          |> trunc()

        if quantity_in_cart > real_stock or quantity_in_cart + quantity > real_stock do
          conn
          |> put_flash(:error_panier, "Il n'a pas assez de stock pour #{item.caption} - Vous avez déja ajouté #{if real_stock < 10, do: "0#{quantity_in_cart}", else: quantity_in_cart} #{item.caption} dans le panier (reste #{real_stock - quantity_in_cart})")
          |> redirect(to: Routes.page_path(conn, :index, id: params["id"]))
        else
          index = Enum.find_index(conn.private[:plug_session]["cart"], &(&1.product_id == item.id))

          # Assigner une nouvelle valeur à la quantité à partir de la position
          # Et mettre à jour le panier dans la session à partir de la nouvelle valeur
          new_cart = List.update_at(conn.private[:plug_session]["cart"], index, fn cart -> %{product_id: item.id, quantity: cart.quantity + quantity} end)

          # Mettre à jour la session avec le nouveau panier
          conn
          |> put_session(:cart, new_cart)
          |> put_session(:sum_cart, Utilities.sum_cart(new_cart))
          |> put_flash(:info_panier, "(#{if quantity_in_cart + quantity < 10, do: "0#{quantity_in_cart + quantity}", else: quantity_in_cart + quantity}) #{product_added_in_cart}")
          |> redirect(to: Routes.page_path(conn, :index, id: params["id"]))
        end
    end
  end

  # Fonction de recherche
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
  #checkout page
  def order_validation(conn, _params) do
    render(
      conn,
      "order_validation.html",
      cart: Plug.Conn.get_session(conn, :cart),
      sum_cart: Plug.Conn.get_session(conn, :sum_cart)
    )
  end
end
