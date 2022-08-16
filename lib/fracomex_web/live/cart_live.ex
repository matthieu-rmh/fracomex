defmodule FracomexWeb.Live.CartLive do
  use FracomexWeb, :live_view

  alias Fracomex.Products

  alias Fracomex.Utilities

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

    {:ok, socket}
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

  # Rechercher des produits
  def handle_event("search-item", %{"q" => q}, socket) do
    {:noreply,
      socket
      |> redirect(to: Routes.product_path(socket, :index, q: q))
    }
  end

  def handle_event("dec-button", params, socket) do
    quantity = String.to_integer(params["quantity"])

    if quantity > 1 do
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
        |> clear_flash()
      }
    else
      {:noreply, socket |> clear_flash()}
    end
  end

  def handle_event("inc-button", params, socket) do
    item_id = params["item_id"]
    caption = Products.get_item!(item_id).caption
    quantity = String.to_integer(params["quantity"])

    real_stock =
      Products.get_item!(item_id).real_stock
      |> Decimal.to_float()
      |> trunc()

    if quantity >= real_stock do
      {:noreply, socket |> put_flash(:error, "Il reste que #{real_stock} quantité pour #{caption}.")}
    else
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
      |> Enum.map(fn cart -> cart.quantity * Utilities.price_to_float(cart.product_id) end)
      |> Enum.sum()
    end
  end

  # Mettre à jour la session avec le nouveau panier
  def handle_event("update-cart", _params, socket) do
    {:noreply,
      socket
      |> redirect(to: Routes.cart_path(socket, :index))
    }
  end

  def handle_event("link-to-product", _params, socket) do
    {:noreply,
      socket
      |> push_redirect(to: Routes.product_path(socket, :index))
    }
  end

  def render(assigns) do
    if is_nil(assigns.cart) do
      FracomexWeb.CartView.render("cart_empty.html", assigns)
    else
      FracomexWeb.CartView.render("cart_live.html", assigns)
    end
  end
end
