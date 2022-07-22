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
        item_families: Products.list_item_families(),
        item_sub_families: Products.list_item_sub_families(),
        cart: session["cart"]
      )

    # IO.puts("**** IREO SESSION ****")
    # IO.inspect(session)

    # IO.puts("**** IREO CART @ SOCKET ****")
    # IO.inspect(socket.assigns.cart)

    {:ok, socket, layout: {FracomexWeb.LayoutView, "layout_live.html"}}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply, put_session_assigns(socket, session)}
  end

  def put_session_assigns(socket, session) do
    socket
    |> assign(user_id: Map.get(session, "user_id"))
    |> assign(cart: Map.get(session, "cart"))
  end

  def handle_event("dec-button", params, socket) do
    quantity = String.to_integer(params["quantity"])

    if quantity > 0 do
      item_id = params["item_id"]

      index = Enum.find_index(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)

      new_cart = List.update_at(socket.assigns.cart, index, fn cart -> %{product_id: item_id, quantity: cart.quantity - 1} end)

      PhoenixLiveSession.put_session(socket, "cart", new_cart)

      {:noreply,
       socket
       |> assign(cart: new_cart)
      }
    else
      {:noreply,
        socket
      }
    end
  end

  def handle_event("inc-button", params, socket) do
    item_id = params["item_id"]

    index = Enum.find_index(socket.assigns.cart, fn cart -> cart.product_id == "#{item_id}" end)

    new_cart = List.update_at(socket.assigns.cart, index, fn cart -> %{product_id: item_id, quantity: cart.quantity + 1} end)

    PhoenixLiveSession.put_session(socket, "cart", new_cart)

    {:noreply,
    socket
     |> assign(cart: new_cart)
    }
  end

  def render(assigns) do
    FracomexWeb.CartView.render("cart_live.html", assigns)
  end
end
