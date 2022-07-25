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
        item_get_by_id: session["item_get_by_id"]
      )

    # IO.inspect(socket)

    {:ok, socket, layout: {FracomexWeb.LayoutView, "layout_live.html"}}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply, put_session_assigns(socket, session)}
  end

  # handle_params: est utilisé pour la gestion de redirection en patch
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("show-product-details", params, socket) do
    # On récupére le produit récupérer par id
    # Pour ensuite l'ajouter dans la session live
    PhoenixLiveSession.put_session(socket, "item_get_by_id", Products.get_item!(params["id"]))

    {:noreply,
      socket
      # push_patch: est utilisé si on utilise un seul "mount"
      # Dans le cas du détail de produit qui est dans la même live controller que produit
      |> push_patch(to: Routes.product_path(socket, :product_details, params["caption"]))
      |> assign(
        item_get_by_id: Products.get_item!(params["id"])
      )
    }
  end

  def handle_event("show-cart-product", _params, socket) do
    {:noreply,
      socket
      |> push_redirect(to: Routes.cart_path(socket, :index))
    }
  end

  def put_session_assigns(socket, session) do
    socket
    |> assign(:user_id, Map.get(session, "user_id"))
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
