defmodule FracomexWeb.Live.ProductLive do
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
        families: Products.list_families_with_subs(),
        sub_families: Products.list_sub_families(),
        quantity: 1,
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

  # Gestion des paramètres dans l'url
  def handle_params(params, _url, socket) do
    id =
      case params["id_produit"]  do
        nil -> nil
        _ -> params["id_produit"]
      end

    categorie =
      case params["categorie"] do
        "famille" ->
          nil

        nil ->
          nil

        _ -> params["categorie"]
      end

    sous_categorie =
      case params["sous_categorie"] do
        "sous-famille" ->
          nil

        nil -> nil
        _-> params["sous_categorie"]
      end

    q =
      cond do
        Utilities.is_empty?(params["q"]) ->
          nil
        true ->
          params["q"]
      end

    page = String.to_integer(params["page"] || "1")

    items = Products.list_items_paginate(params)
    families = Products.list_families_paginate(params)

    cond do
      # Si q ou recherche est spécifié, on charge le produit contenant la valeur recherché par nom
      not is_nil(q) ->
        search_item = Products.search_item(q)

        if search_item.entries == [] do
          {:noreply,
            socket
            |> push_redirect(to: Routes.product_path(socket, :empty_items))
          }
        else
          {:noreply,
            socket
            |> assign(options: page)
            |> assign(items: items)
            |> assign(families: families)
            |> assign(items: search_item)
          }
        end

      # Si l'id est spécifié, on charge le produit
      not is_nil(id) ->
        item = Products.get_item_with_family_and_sub_family!(id)

        {:noreply,
          socket
          |> assign(options: page)
          |> assign(items: items)
          |> assign(families: families)
          |> assign(item: item)
        }

      # Si la sous-catégorie est spécifiée, on charge la liste des produits de cette sous-catégorie
      not is_nil(sous_categorie) ->
        sub_family_id = Products.get_sub_family_id_by_caption!(sous_categorie)

        if is_nil(sub_family_id) do
          IO.inspect(socket.assigns)

          {:noreply,
            socket
            |> put_flash(:info, "La sous-famille n'existe pas")
            |> assign(options: page)
            |> assign(items: items)
            |> assign(families: families)
            |> push_redirect(to: Routes.product_path(socket, :index))
          }
        else
          sub_family = Products.get_sub_family!(sub_family_id)
          family_id = Products.get_sub_family!(sub_family_id).family_id
          family = Products.get_family!(family_id)

          items_by_sub_family_id = Products.get_item_by_sub_family!(sub_family_id, params)

          case items_by_sub_family_id.entries do
            [] ->
              {:noreply,
                socket
                |> assign(options: page)
                |> assign(items: items)
                |> assign(families: families)
                |> push_redirect(to: Routes.product_path(socket, :empty_items))
              }

            _ ->
              {:noreply,
                socket
                |> assign(options: page)
                |> assign(items: items)
                |> assign(families: families)
                |> assign(items_by_sub_family_id: items_by_sub_family_id)
                |> assign(family: family)
                |> assign(sub_family: sub_family)
              }
          end
        end

      # Si la catégorie est spécifiée, on charge la liste des sous-catégories de cette catégorie
      not is_nil(categorie) ->
        family_id = Products.get_family_id_by_caption!(categorie)

        if is_nil(family_id) do
          {:noreply,
            socket
            |> put_flash(:info, "La famille n'existe pas")
            |> assign(options: page)
            |> assign(items: items)
            |> assign(families: families)
            |> push_redirect(to: Routes.product_path(socket, :index))
          }
        else
          families = Products.get_family_with_its_subs!(family_id)
          sub_families = families.sub_families

          {:noreply, socket |> assign(sub_families_by_family_id: sub_families)}
        end

      true ->
        {:noreply,
          socket
          |> assign(options: page)
          |> assign(items: items)
          |> assign(families: families)
        }
    end
  end

  # Rechercher des produits
  def handle_event("search-item", %{"q" => q}, socket) do
    {:noreply,
      socket
      |> redirect(to: Routes.product_path(socket, :index, q: q))
    }
  end

  # Afficher les sous-catégories appartenant à la catégorie
  def handle_event("show-sub-family", %{"id" => id}, socket) do
    families = Products.get_family_with_its_subs!(id)

    {:noreply,
      socket
      |> push_patch(to: Routes.product_path(socket, :family, families.caption))
    }
  end

  def handle_event("show-product-details", params, socket) do
    id = params["id"]
    item = Products.get_item_with_family_and_sub_family!(id)

    # family =
    #   item.family.caption
    #   |> String.replace(" ", "-")

    # sub_family =
    #   item.sub_family.caption
    #   |> String.replace(" ", "-")

    caption =
      item.caption
      |> String.replace(" ", "-")

    {:noreply,
     socket
     |> push_redirect(to: Routes.product_path(socket, :product_details, item.family.caption, item.sub_family.caption, caption, id))}
  end

  def handle_event("add-product-to-cart", params, socket) do
    item_id = params["item_id"]
    item = Products.get_item_with_family_and_sub_family!(item_id)
    quantity = String.to_integer(params["quantity"])

    product_added_in_cart = "#{item.caption} a été ajouté au panier"

    real_stock = Decimal.to_integer(item.real_stock)

    if quantity == 0 or quantity > real_stock do
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

          # family =
          #   item.family.caption
          #   |> String.replace(" ", "-")

          # sub_family =
          #   item.sub_family.caption
          #   |> String.replace(" ", "-")

          caption =
            item.caption
            |> String.replace(" ", "-")

          {:noreply,
           socket
           |> put_flash(:info, "(#{if quantity < 10, do: "0#{quantity}", else: quantity}) #{product_added_in_cart}")
           |> assign(cart: [cart])
           |> redirect(to: Routes.product_path(socket, :product_details, item.family.caption, item.sub_family.caption, caption, item_id))
          }

        is_nil(Enum.find(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)) ->
          cart = %{
            product_id: item_id,
            quantity: quantity
          }

          PhoenixLiveSession.put_session(socket, "cart", socket.assigns.cart ++ [cart])
          PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(socket.assigns.cart ++ [cart]))

          # family =
          #   item.family.caption
          #   |> String.replace(" ", "-")

          # sub_family =
          #   item.sub_family.caption
          #   |> String.replace(" ", "-")

          caption =
            item.caption
            |> String.replace(" ", "-")

          {:noreply,
           socket
           |> put_flash(:info, "(#{if quantity < 10, do: "0#{quantity}", else: quantity}) #{product_added_in_cart}")
           |> assign(cart: socket.assigns.cart ++ [cart])
           |> redirect(to: Routes.product_path(socket, :product_details, item.family.caption,  item.sub_family.caption, caption, item_id))
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

            # family =
            #   item.family.caption
            #   |> String.replace(" ", "-")

            # sub_family =
            #   item.sub_family.caption
            #   |> String.replace(" ", "-")

            caption =
              item.caption
              |> String.replace(" ", "-")

            {:noreply,
             socket
             |> put_flash(:info, "(#{if quantity_in_cart + quantity < 10, do: "0#{quantity_in_cart + quantity}", else: quantity_in_cart + quantity}) #{product_added_in_cart}")
             |> assign(cart: new_cart)
             |> redirect(to: Routes.product_path(socket, :product_details,  item.family.caption, item.sub_family.caption, caption, item_id))
            }
          end
      end
    end
  end

  def handle_event("add-one-product-to-cart", params, socket) do
    item = Products.get_item_with_family_and_sub_family!(params["id"])

    quantity = 1

    product_added_in_cart = "#{item.caption} a été ajouté au panier"

    cond do
      is_nil(socket.assigns.cart) ->
        cart = %{
          product_id: item.id,
          quantity: quantity
        }

        PhoenixLiveSession.put_session(socket, "cart", [cart])
        PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart([cart]))

        {:noreply,
          socket
          |> put_flash(:info, "(0#{quantity}) #{product_added_in_cart}")
          |> assign(cart: [cart])
          |> redirect(to: Routes.product_path(socket, :index))
        }

      is_nil(Enum.find(socket.assigns.cart, fn cart -> cart.product_id == "#{item.id}" end)) ->
        cart = %{
          product_id: item.id,
          quantity: quantity
        }

        PhoenixLiveSession.put_session(socket, "cart", socket.assigns.cart ++ [cart])
        PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(socket.assigns.cart ++ [cart]))

        {:noreply,
          socket
          |> put_flash(:info, "(0#{quantity}) #{product_added_in_cart}")
          |> assign(cart: socket.assigns.cart ++ [cart])
          |> redirect(to: Routes.product_path(socket, :index))
        }

      true ->

        # Retrouver la position de l'item dans le panier
        quantity_in_cart = Enum.find(socket.assigns.cart, &(&1.product_id == item.id)).quantity

        real_stock =
          Products.get_item!(item.id).real_stock
          |> Decimal.to_float()
          |> trunc()

        if quantity_in_cart > real_stock or quantity_in_cart + quantity > real_stock do
          {:noreply, socket |> put_flash(:error, "Il n'a pas assez de stock pour #{item.caption} - Vous avez déja ajouté #{if real_stock < 10, do: "0#{quantity_in_cart}", else: quantity_in_cart} #{item.caption} dans le panier (reste #{real_stock - quantity_in_cart})")}
        else
          index = Enum.find_index(socket.assigns.cart, &(&1.product_id == item.id))

          # Assigner une nouvelle valeur à la quantité à partir de la position
          # Et mettre à jour le panier dans la session à partir de la nouvelle valeur
          new_cart = List.update_at(socket.assigns.cart, index, fn cart -> %{product_id: item.id, quantity: cart.quantity + quantity} end)

          # Mettre à jour la session avec le nouveau panier
          PhoenixLiveSession.put_session(socket, "cart", new_cart)
          PhoenixLiveSession.put_session(socket, "sum_cart", sum_cart(new_cart))

          {:noreply,
            socket
            |> put_flash(:info, "(#{if quantity_in_cart + quantity < 10, do: "0#{quantity_in_cart + quantity}", else: quantity_in_cart + quantity}) #{product_added_in_cart}")
            |> assign(cart: new_cart)
            |> redirect(to: Routes.product_path(socket, :index))
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

  def handle_event("paginate-items-in-sub-family", params, socket) do
    family = %{"caption" => params["family"]}
    sub_family = %{"caption" => params["sub_family"]}
    page = params["page"]


    {:noreply, push_redirect(socket, to: Routes.product_path(socket, :sub_family, family["caption"], sub_family["caption"], page: page))}
  end

  def render(assigns) do
    case assigns.live_action do
      :index ->
        FracomexWeb.ProductView.render("product_live.html", assigns)
      :family ->
        FracomexWeb.ProductView.render("family_live.html", assigns)
      :sub_family ->
        FracomexWeb.ProductView.render("sub_family_live.html", assigns)
      :product_details ->
        FracomexWeb.ProductView.render("single_product_live.html", assigns)
      :empty_items ->
        FracomexWeb.ProductView.render("empty_items_live.html", assigns)
    end
  end
end
