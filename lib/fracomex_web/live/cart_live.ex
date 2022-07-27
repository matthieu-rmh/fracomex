defmodule FracomexWeb.Live.CartLive do
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
        cart: session["cart"],
        sum_cart: sum_cart(session["cart"])
      )

    {:ok, socket, layout: {FracomexWeb.LayoutView, "layout_live.html"}}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply, put_session_assigns(socket, session)}
  end

  def put_session_assigns(socket, session) do
    socket
    |> assign(user_id: Map.get(session, "user_id"))
    |> assign(cart: Map.get(session, "cart"))
    |> assign(sum_cart: sum_cart(session["cart"]))
  end

  def handle_event("dec-button", params, socket) do
    quantity = String.to_integer(params["quantity"])

    if quantity > 0 do
      item_id = params["item_id"]

      # Retrouver la position de l'item dans le panier
      index = Enum.find_index(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)

      # Assigner une nouvelle valeur à la quantité à partir de la position
      # Et mettre à jour le panier dans la session à partir de la nouvelle valeur
      new_cart =
        List.update_at(socket.assigns.cart, index, fn cart ->
          %{product_id: item_id, quantity: cart.quantity - 1}
        end)

      # Mettre à jour la session avec le nouveau panier
      PhoenixLiveSession.put_session(socket, "cart", new_cart)
      PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(new_cart))

      {:noreply,
        socket
        |> assign(cart: new_cart)
        |> assign(sum_cart: sum_cart(new_cart))
      }
    else
      {:noreply, socket}
    end
  end

  def handle_event("inc-button", params, socket) do
    item_id = params["item_id"]

    # Retrouver la position de l'item dans le panier
    index = Enum.find_index(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)

    # Assigner une nouvelle valeur à la quantité à partir de la position
    # Et mettre à jour le panier dans la session à partir de la nouvelle valeur
    new_cart =
      List.update_at(socket.assigns.cart, index,
                      fn cart ->
                        %{product_id: item_id, quantity: cart.quantity + 1}
                      end
                    )

    # Mettre à jour la session avec le nouveau panier
    PhoenixLiveSession.put_session(socket, "cart", new_cart)
    PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(new_cart))

    {:noreply,
      socket
      |> assign(cart: new_cart)
      |> assign(sum_cart: sum_cart(new_cart))
    }
  end

  def handle_event("remove-item-from-cart", params, socket) do
    id = params["id"]

    # Retrouver la position de l'item dans le panier
    index = Enum.find_index(socket.assigns.cart, fn cart -> cart.product_id == "#{id}" end)

    new_cart = List.delete_at(socket.assigns.cart, index)

    PhoenixLiveSession.put_session(socket, "cart", new_cart)
    PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(new_cart))

    {:noreply,
      socket
      |> assign(cart: new_cart)
      |> assign(sum_cart: sum_cart(new_cart))
      |> redirect(to: Routes.cart_path(socket, :index))
    }
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
    FracomexWeb.CartView.render("cart_live.html", assigns)
  end
end
