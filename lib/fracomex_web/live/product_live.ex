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
        item_families: Products.list_item_families(),
        item_sub_families: Products.list_item_sub_families(),
        quantity: 0,
        cart: session["cart"]
      )

    IO.puts("NY ATO ANATY SOCKET")
    IO.inspect(socket.assigns.cart)

    {:ok, socket, layout: {FracomexWeb.LayoutView, "layout_live.html"}}
  end

  def handle_info({:live_session_updated, session}, socket) do
    IO.puts("NY ATO ANATY SESSION")
    IO.inspect(session["cart"])

    {:noreply,
     socket
     |> assign(cart: session["cart"])
     |> put_session_assigns(session)}
  end

  # handle_params: est utilisé pour récupérer les données passé dans l'url
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
     # push_patch: est utilisé si on utilise un seul "mount"
     # Dans le cas du détail de produit qui est dans la même live controller que produit
     |> push_redirect(to: Routes.product_path(socket, :product_details, item_caption, item_id))}
  end

  # def handle_event("sub", params, socket) do
  #   list_panier = socket.assigns.list_panier
  #   list_quantite = socket.assigns.list_quantite
  #   index = Enum.find_index(list_panier, fn x -> x == params["idp"] end)
  #   quantite = minus(Enum.fetch!(list_quantite, index))
  #   list_quantite = List.update_at(list_quantite, index, &(&1 - &1 + quantite))
  #   somme = somme_prix(list_quantite, list_panier, socket.assigns.produits)
  #   {:noreply, socket |> assign(somme: somme, list_quantite: list_quantite)}
  # end

  # def handle_event("add", params, socket) do
  #   list_panier = socket.assigns.list_panier
  #   list_quantite = socket.assigns.list_quantite
  #   produit = ProdRequette.get_produit_by_id_produit(params["idp"])
  #   max = produit.stockmax |> Decimal.to_integer
  #   index = Enum.find_index(list_panier, fn x -> x == params["idp"] end)
  #   quantite = maxus(Enum.fetch!(list_quantite, index), max)
  #   list_quantite = List.update_at(list_quantite, index, &(&1 - &1 + quantite))
  #   somme = somme_prix(list_quantite, list_panier, socket.assigns.produits)
  #   {:noreply, socket |> assign(somme: somme, list_quantite: list_quantite)}
  # end

  # def handle_event("sup", params, socket) do
  #   list_panier = socket.assigns.list_panier
  #   list_quantite = socket.assigns.list_quantite
  #   index = Enum.find_index(list_panier, fn x -> x == params["idp"] end)
  #   list_panier = List.delete_at(list_panier, index)
  #   list_quantite = List.delete_at(list_quantite, index)
  #   produits = list_panier |> produits_
  #   somme = somme_prix(list_quantite, list_panier, produits)
  #   {:noreply, socket |> assign(somme: somme, list_quantite: list_quantite, list_panier: list_panier, produits: produits) |> put_flash(:error, "Produit effacé !!")}
  # end

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

          {:noreply,
           socket

           |> put_flash(:info, product_added_in_cart)
           |> redirect(to: Routes.product_path(socket, :product_details, item.caption, item_id))
           |> assign(cart: socket.assigns.cart ++ [cart])
          }

        true ->
          index = Enum.find_index(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)

          new_cart = List.update_at(socket.assigns.cart, index, fn cart -> %{product_id: item_id, quantity: cart.quantity + quantity} end)

          PhoenixLiveSession.put_session(socket, "cart", new_cart)

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
      {:noreply,
        socket
        |> assign(quantity: quantity - 1)
      }
    else
      {:noreply,
        socket
      }
    end
  end

  def handle_event("inc-button", params, socket) do
    quantity = String.to_integer(params["quantity"])

    {:noreply,
      socket
      |> assign(quantity: quantity + 1)
    }
  end

  def put_session_assigns(socket, session) do
    socket
    |> assign(user_id: Map.get(session, "user_id"))
    |> assign(cart: Map.get(session, "cart"))
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
