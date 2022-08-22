defmodule Fracomex.Utilities do

  alias Fracomex.Products

  def get_page_title_tag(request_path, user_id) do
    uid = cond do
      not is_nil(user_id) -> user_id
      true -> ""
    end

    modif_mdp = "/modifier-motdepasse/#{uid}"
    modif_profil = "/modifier-profil/#{uid}"
    modif_adresse = "/modifier-adresse/#{uid}"

    case request_path do

      "/" -> "Eléctricité | Quincaillerie | Sanitaire"
      "/boutique" -> "Boutique"
      "/panier" -> "Panier"
      "/connexion" -> "Connexion"
      "/inscription" -> "Inscription"
      "/verification-confirmation-mail" -> "Vérification"
      "/verification-mdp-oublie" -> "Vérification"
      "/mdp-oublie" -> "Vérification"
      "/renvoi-verification-mail" -> "Vérification"
      "/mon-profil" -> "Mon profil"
      "/mon-adresse" -> "Mon adresse"
      "/mes-commandes" -> "Mes commandes"
      "/valider-connexion" -> "Validation"
      "/valider-inscription" -> "Validation"
      "/envoi-mail-mdp-oublie" -> "Envoi"
      "/renvoi-mail-confirmation" -> "Envoi"
      ^modif_mdp -> "Modification"
      ^modif_profil -> "Modification"
      ^modif_adresse -> "Modification"
      "/validation-panier" -> "Validation panier"
      "/valider-commande" -> "Validation commande"
      _ -> "Fracomex"

    end

  end


  # Transformer le prix décimal en float
  def price_to_float(id) do
    Products.get_item!(id).sale_price_vat_excluded
    |> Decimal.to_float()
  end

  # Récupérer les informations des produits dans le panier
  def product_in_cart(cart, i) do
    Enum.at(cart, i).product_id
    |> Products.get_item_with_its_family_and_sub_family!()
  end

  # RÉCUPÉRATION DES ARTICLES ET QUANTITÉ DANS LE PANIER
  def get_items_from_cart(cart) do
    cart
    |> Enum.map(fn %{product_id: product_id, quantity: quantity} ->
      %{item: Products.get_item!(product_id), quantity: quantity}
     end)
  end

  def price_format(price) do
    :erlang.float_to_binary(Decimal.to_float(price), [decimals: 2]) |> String.replace(".", ",")
  end

  def price_format_from_float(price) do
    :erlang.float_to_binary(price, [decimals: 2]) |> String.replace(".", ",")
  end

  # Vérifie si un champ est vide ou seulement remplie par des espaces
  def is_empty?(params) do
    if not is_nil(params) do
      is_empty =
        params
        |> String.trim()
        |> String.length()

      if is_empty == 0, do: true, else: false
    end
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

  # GENERATION DE NUMÉRO DE COMMANDE
  def generate_order_id do
    date =
      NaiveDateTime.local_now()
        |> NaiveDateTime.to_date()
        |> Date.to_string()
        |> String.split("-")
        |> List.to_string()

      order_id = date<>"#{generate_random_three_digits_number()}"

      cond do
        not Products.order_id_already_exist?(order_id) ->
          order_id
        true ->
          generate_order_id()
      end

  end

  # GENERATION D'UN NOMBRE ALÉATOIRE DE TROIS CHIFFRES
  def generate_random_three_digits_number do
    Enum.random(100..999)
  end

  # HEURE DU SERVEUR DISTANT
  def get_remote_naive_date do
    NaiveDateTime.local_now() |> NaiveDateTime.add(10800)
  end

  def print_order_status(conn, order) do
    cond do
      order.checked_out ->
        "PAYÉ"
      true ->
        cond do
          Plug.Conn.get_session(conn, :current_order) == order.id ->
            "PANIER EN COURS"
          true ->
            "ABANDONNÉE"
        end
    end
  end

  def status_order_color(status) do
    cond do
      status == "PAYÉ" ->
        "green"
      status == "PANIER EN COURS" ->
        "yellowgreen"
      true ->
        "red"
    end
  end

  def explicit_format_date_from_naive(naive_datetime) do
    Calendar.strftime(naive_datetime,"%A %d %B %Y, (%d/%m/%Y) %Hh %M",
    day_of_week_names: fn day_of_week ->
      {"Lundi", "Mardi", "Mercredi", "Jeudi",
      "Vendredi", "Samedi", "Dimanche"}
      |> elem(day_of_week - 1)
    end,
    month_names: fn month ->
      {"Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"}
      |> elem(month - 1)
    end
   )
  end
end
