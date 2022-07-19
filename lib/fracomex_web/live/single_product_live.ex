defmodule FracomexWeb.Live.SingleProductLive do
  use FracomexWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      socket
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)

    # IO.inspect(socket)

    {:ok, socket, layout: {FracomexWeb.LayoutView, "layout_live.html"}}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply, put_session_assigns(socket, session)}
  end

  def put_session_assigns(socket, session) do
    socket
    |> assign(:user_id, Map.get(session, "user_id"))
  end

  def render(assigns) do
    FracomexWeb.SingleProductView.render("single_product_live.html", assigns)
  end
end
