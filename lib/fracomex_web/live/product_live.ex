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
        families: Products.list_families_with_subs(),
        sub_families: Products.list_sub_families(),
        quantity: 0,
        cart: session["cart"],
        sum_cart: session["sum_cart"]
      )

    {:ok, socket}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply,
     socket
     |> assign(cart: session["cart"])
     |> put_session_assigns(session)}
  end

  def handle_params(params, _url, socket) do
    item_id = params["id_produit"]

    items = Products.list_items_paginate(params)
    families = Products.list_families_paginate(params)

    if not is_nil(item_id) do
      item_get_by_id = Products.get_item_with_family_and_sub_family!(item_id)

      {:noreply,
        socket
        |> assign(item_get_by_id: item_get_by_id)
      }
    else
      {:noreply,
        socket
        |> assign(items: items)
        |> assign(families: families)
      }
    end
  end

  def handle_event("show-product-details", params, socket) do
    id = params["id"]
    item = Products.get_item_with_family_and_sub_family!(id)

    {:noreply,
     socket
     |> push_redirect(to: Routes.product_path(socket, :product_details, item.family.caption, item.sub_family.caption, item.caption, id))}
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
           |> assign(cart: [cart])
           |> redirect(to: Routes.product_path(socket, :product_details, item.family.caption, item.sub_family.caption, item.caption, item_id))
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
           |> assign(cart: socket.assigns.cart ++ [cart])
           |> redirect(to: Routes.product_path(socket, :product_details, item.family.caption, item.sub_family.caption, item.caption, item_id))
          }

        true ->
          # Retrouver la position de l'item dans le panier

          quantity_in_cart = Enum.find(socket.assigns.cart, &(&1.product_id == item_id)).quantity

          real_stock =
            Products.get_item!(item_id).real_stock
            |> Decimal.to_float()
            |> trunc()

          if quantity_in_cart > real_stock or quantity_in_cart + quantity > real_stock do
            {:noreply, socket |> put_flash(:error, "Il n'a pas assez de stock pour #{item.caption} - Vous avez déja ajouté #{if real_stock < 10, do: "0#{quantity_in_cart}", else: quantity_in_cart} #{item.caption} dans le panier (reste #{real_stock - quantity_in_cart})")}
          else
            index = Enum.find_index(socket.assigns.cart, &(&1.product_id == item_id))

            # Assigner une nouvelle valeur à la quantité à partir de la position
            # Et mettre à jour le panier dans la session à partir de la nouvelle valeur
            new_cart = List.update_at(socket.assigns.cart, index, fn cart -> %{product_id: item_id, quantity: cart.quantity + quantity} end)

            # Mettre à jour la session avec le nouveau panier
            PhoenixLiveSession.put_session(socket, "cart", new_cart)
            PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(new_cart))

            {:noreply,
             socket
             |> put_flash(:info, product_added_in_cart)
             |> assign(cart: new_cart)
             |> redirect(to: Routes.product_path(socket, :product_details, item.family_id, item.sub_family_id, item.caption, item_id))
            }
          end
      end
    end
  end

  def handle_event("dec-button", params, socket) do
    quantity = String.to_integer(params["quantity"])

    if quantity > 0 do
      {:noreply,
        socket
        |> assign(quantity: quantity - 1)
        |> clear_flash()
      }
    else
      {:noreply, socket |> clear_flash()}
    end
  end

  def handle_event("inc-button", params, socket) do
    id = params["item_id"]
    quantity = String.to_integer(params["quantity"])
    caption = Products.get_item!(id).caption

    real_stock =
      Products.get_item!(id).real_stock
      |> Decimal.to_float()
      |> trunc()

    if quantity >= real_stock do
      {:noreply, socket |> put_flash(:error, "Il n'a pas assez de stock pour #{caption} (reste #{real_stock})")}
    else
      {:noreply, socket |> assign(quantity: quantity + 1)}
    end
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

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, push_redirect(socket, to: Routes.product_path(socket, :index, page: page))}
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
