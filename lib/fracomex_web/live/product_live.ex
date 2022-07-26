defmodule FracomexWeb.Live.ProductLive do
  use FracomexWeb, :live_view

  alias Fracomex.Products

  def mount(_params, session, socket) do

    socket =
      socket
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)
      |> assign(
        items: Products.list_items(),
        families: Products.list_families(),
        sub_families: Products.list_sub_families(),
        quantity: 0,
        cart: session["cart"],
        sum_cart: session["sum_cart"]
      )

    {:ok, socket, layout: {FracomexWeb.LayoutView, "layout_live.html"}}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply,
     socket
     |> assign(cart: session["cart"])
     |> put_session_assigns(session)}
  end

  def handle_params(params, _url, socket) do
    item_id = params["id_produit"]

    if not is_nil(item_id) do
      item_get_by_id = Products.get_item!(item_id)

      {:noreply, socket |> assign(item_get_by_id: item_get_by_id)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("show-product-details", params, socket) do
    item_id = params["id"]
    item_caption = params["caption"]

    {:noreply,
     socket
     |> push_redirect(to: Routes.product_path(socket, :product_details, item_caption, item_id))}
  end

  def handle_event("add-product-to-cart", params, socket) do
    item_id = params["item_id"]
    item = Products.get_item!(item_id)
    quantity = String.to_integer(params["quantity"])

    product_added_in_cart = "(#{quantity}) #{item.caption} a été ajouté au panier"

    if quantity == 0 do
      {:noreply, socket}
    else
      cond do
        is_nil(socket.assigns.cart) ->
          cart = %{
            product_id: item_id,
            quantity: quantity
          }

          PhoenixLiveSession.put_session(socket, "cart", [cart])
          PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart([cart]))

          {:noreply,
           socket
           |> put_flash(:info, product_added_in_cart)
           |> redirect(to: Routes.product_path(socket, :product_details, item.caption, item_id))
           |> assign(cart: [cart])
          }

        is_nil(Enum.find(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)) ->
          cart = %{
            product_id: item_id,
            quantity: quantity
          }

          PhoenixLiveSession.put_session(socket, "cart", socket.assigns.cart ++ [cart])
          PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(socket.assigns.cart ++ [cart]))

          {:noreply,
           socket
           |> put_flash(:info, product_added_in_cart)
           |> redirect(to: Routes.product_path(socket, :product_details, item.caption, item_id))
           |> assign(cart: socket.assigns.cart ++ [cart])
          }

        true ->
          # Retrouver la position de l'item dans le panier
          index = Enum.find_index(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)

          # Assigner une nouvelle valeur à la quantité à partir de la position
          # Et mettre à jour le panier dans la session à partir de la nouvelle valeur
          new_cart = List.update_at(socket.assigns.cart, index, fn cart -> %{product_id: item_id, quantity: cart.quantity + quantity} end)

          # Mettre à jour la session avec le nouveau panier
          PhoenixLiveSession.put_session(socket, "cart", new_cart)
          PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(new_cart))

          {:noreply,
           socket
           |> put_flash(:info, product_added_in_cart)
           |> redirect(to: Routes.product_path(socket, :product_details, item.caption, item_id))
           |> assign(cart: new_cart)
          }
      end
    end
  end

  def handle_event("dec-button", params, socket) do
    quantity = String.to_integer(params["quantity"])

    if quantity > 0 do
      {:noreply, socket |> assign(quantity: quantity - 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("inc-button", params, socket) do
    quantity = String.to_integer(params["quantity"])

    {:noreply, socket |> assign(quantity: quantity + 1)}
  end

  def put_session_assigns(socket, session) do
    socket
    |> assign(user_id: Map.get(session, "user_id"))
    |> assign(cart: Map.get(session, "cart"))
  end

  # Calculer la somme totale du panier
  def sum_cart(cart) do
    if is_nil(cart) do
      0
    else
      cart
      |> Enum.map(fn cart -> cart.quantity * Decimal.to_float Products.get_item!(cart.product_id).sale_price_vat_excluded end)
      |> Enum.sum()
    end
  end

  def render(assigns) do
    # On récupère l'atome de l'url de la page actuelle
    # Si :index, on affiche la page boutique
    # Sinon, on affiche la page détail du produit
    if assigns.live_action == :index do
      FracomexWeb.ProductView.render("product_live.html", assigns)
    else
      FracomexWeb.ProductView.render("single_product_live.html", assigns)
    end
  end
end
