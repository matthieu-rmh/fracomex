defmodule FracomexWeb.PageController do
  use FracomexWeb, :controller

  alias Fracomex.{Products, Utilities, Accounts, UserEmail}

  def send_contact_mail(conn, params) do

    mail = params["mail"]
    name = params["name"]
    subject = params["subject"]
    message = params["message"]

    UserEmail.send_contact_mail(mail, name, subject, message)
    conn
    |> put_flash(:info, "Votre message a bien été envoyé.")
    |> redirect(to: "/")
  end

  # RÉSUMÉ DE LA COMMANDE AVANT PAIEMENT
  def recap_order(conn, %{"nil" => %{"cvg_accepted" => cvg_accepted}, "order_id" => order_id}) do
    # IO.puts "RECAP"
    # IO.inspect(cvg_accepted)
    # IO.inspect(order_id)
    date = Utilities.get_remote_naive_date() |> Utilities.explicit_format_date_from_naive()
    cond do
      cvg_accepted == "false" ->
        render(conn, "order_validation.html",
            cart: get_session(conn, :cart),
            sum_cart: get_session(conn, :sum_cart),
            selected_family_id: Plug.Conn.get_session(conn, :selected_family_id),
            order: Products.get_order_with_lines_and_items(order_id),
            not_accepted_error_message: "Veuillez accepter les conditions avant de poursuivre"
            )
      true ->
        render(conn, "recap_order.html",
                cart: get_session(conn, :cart),
                sum_cart: get_session(conn, :sum_cart),
                selected_family_id: Plug.Conn.get_session(conn, :selected_family_id),
                order: Products.get_order(order_id),
                date: date
                )

    end

  end

  # VALIDATION DE COMMANDE
  def submit_order(conn, %{"order_id" => order_id}) do
    user_id = get_session(conn, :user_id)

    cond do
      is_nil user_id ->
        conn
        |> put_flash(:error, "Veuillez vous connecter avant de procéder à la commande")
        |> redirect(to: "/connexion")

      true ->
        user = Accounts.get_user!(user_id)
        cond do
          is_nil(user.street) ->
            conn
            |> put_flash(:error, "Veuillez renseigner votre adresse avant de procéder à la commande")
            |> redirect(to: "/mon-adresse")
          true ->
            render(conn, "order_validation.html",
            cart: get_session(conn, :cart),
            sum_cart: get_session(conn, :sum_cart),
            selected_family_id: Plug.Conn.get_session(conn, :selected_family_id),
            order: Products.get_order_with_lines_and_items(order_id),
            not_accepted_error_message: nil
            )
        end
    end

  end

  # Fonction ajout de produit dans le panier
  def add_to_cart(conn, params) do
    item = Products.get_item_with_family_and_sub_family!(params["id"])

    quantity = 1

    product_added_in_cart = "#{item.caption} a été ajouté au panier"

    cond do
      is_nil(conn.private[:plug_session]["cart"]) ->
        IO.puts "COND 1 [ADD NEW ORDER AND NEW LINE]"
        cart = %{
          product_id: item.id,
          quantity: quantity
        }

        sum = Utilities.sum_cart([cart])

        {:ok, order} = Products.create_order(
          %{
            "user_id" => get_session(conn, :user_id),
            "sum" => sum
          })


        Products.create_order_line(%{
          "order_id" => order.id,
          "item_id" => item.id,
          "user_id" => get_session(conn, :user_id),
          "quantity" => quantity
        })

        conn
        |> put_session(:cart, [cart])
        |> put_session(:sum_cart, sum)
        |> put_session(:current_order, order.id)
        |> put_session(:selected_family_id, Plug.Conn.get_session(conn, :selected_family_id))
        |> put_flash(:info_panier, "(0#{quantity}) #{product_added_in_cart}")
        |> redirect(to: Routes.page_path(conn, :index, id: params["id"]))


      is_nil(Enum.find(conn.private[:plug_session]["cart"], fn cart -> cart.product_id == "#{item.id}" end)) ->
        IO.puts "COND 2 [ADD NEW LINE TO CURRENT ORDER OR ADD NEW ORDER IF CART IS EMPTY]"
        cart = %{
          product_id: item.id,
          quantity: quantity
        }

        order = cond do
          # SI LE PANIER N'EST PAS VIDE DONC UNE COMMANDE EST EN COURS
          get_session(conn, :cart) != [] and not is_nil(get_session(conn, :current_order)) ->
            order_id = get_session(conn, :current_order)

            current_order = Products.get_order(order_id)

            {:ok, order_line} = Products.create_order_line(%{
              "order_id" => current_order.id,
              "item_id" => item.id,
              "user_id" => get_session(conn, :user_id),
              "quantity" => quantity
            })

            item = Products.get_item!(order_line.item_id)
            updated_quantity = Decimal.add current_order.sum, (Decimal.mult(item.sale_price_vat_excluded, quantity))
            Products.update_order(current_order, %{"sum" => updated_quantity})
            current_order
          # SI LE PANIER EST VIDE / AUCUNE COMMANDE EN COURS
          true ->
            sum = Utilities.sum_cart([cart]) |> Decimal.from_float()
            {:ok, new_order} = Products.create_order(
              %{
                "user_id" => get_session(conn, :user_id),
                "sum" => sum
              })

              Products.create_order_line(%{
                "order_id" => new_order.id,
                "item_id" => item.id,
                "user_id" => get_session(conn, :user_id),
                "quantity" => quantity
              })
              new_order
        end

        conn
        |> put_session(:cart, conn.private[:plug_session]["cart"] ++ [cart])
        |> put_session(:sum_cart, Utilities.sum_cart(conn.private[:plug_session]["cart"] ++ [cart]))
        |> put_session(:current_order, order.id)
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
          IO.puts "COND 3 [UPDATE CORRESPONDING ORDER_LINE QUANTITY FROM CURRENT ORDER]"

          current_order_id = get_session(conn, :current_order)
          current_order = Products.get_order_with_lines(current_order_id)

          added_order_line = Enum.find(current_order.order_lines, &(&1.item_id==item.id))
          item = Products.get_item!(added_order_line.item_id)

          new_sum =  Decimal.add current_order.sum, (Decimal.mult(item.sale_price_vat_excluded, quantity))
          new_quantity = added_order_line.quantity + quantity

          Products.update_order(current_order, %{"sum" => new_sum})
          IO.inspect Products.update_order_line(added_order_line, %{"quantity" => new_quantity})

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
    slides_files = Application.get_env(:fracomex, :slides_files)
    indexes = slides_files
    |> Enum.with_index
    |> Enum.map(fn {_filename, index} ->
      index
    end)

    slides_files_with_indexes = Application.get_env(:fracomex, :slides_files)
    |> Enum.with_index
    |> Enum.map(fn {filename, index} ->
      {filename, index+1}
    end)

    render(
      conn,
      "index.html",
      slides_files: slides_files_with_indexes,
      indexes: indexes,
      items: Products.list_items_arrival(),
      families: Products.list_families(),
      sub_families: Products.list_sub_families(),
      cart: Plug.Conn.get_session(conn, :cart),
      sum_cart: Plug.Conn.get_session(conn, :sum_cart),
      selected_family_id: Plug.Conn.get_session(conn, :selected_family_id)
    )

    # render(conn, "arrivage.html")
  end
  #contact page
  def contact(conn, _params) do
    render(
      conn,
      "contact.html",
      cart: Plug.Conn.get_session(conn, :cart),
      sum_cart: Plug.Conn.get_session(conn, :sum_cart),
      selected_family_id: Plug.Conn.get_session(conn, :selected_family_id)
    )
  end

  #PAGE DE VALIDATION DE PANIER
  def validate_cart(conn, _params) do

    IO.inspect get_session(conn, :cart)
    IO.inspect get_session(conn, :sum_cart)
    IO.inspect get_session(conn, :current_order)

    user_id = get_session(conn, :user_id)
    cart = get_session(conn, :cart)
    sum_cart = get_session(conn, :sum_cart)

    cond do
      # SI L'UTILISATEUR N'EST PAS ENCORE CONNECTÉ
      is_nil(user_id) ->
        conn
        |> put_flash(:error, "Veuillez vous connecter avant de valider votre panier s'il vous plaît.")
        |> redirect(to: "/connexion")

      true ->
        cond do
          # SI LE PANIER DE L'UTILISATEUR EST VIDE
          is_nil(cart) ->
            redirect(conn, to: "/panier")

            true ->

              # SI TOUT SE PASSE BIEN
              cart_items = Utilities.get_items_from_cart(cart)
              render(conn, "cart_validation.html", cart: cart, sum_cart: sum_cart, cart_items: cart_items, selected_family_id: Plug.Conn.get_session(conn, :selected_family_id))
        end
    end

  end
end
