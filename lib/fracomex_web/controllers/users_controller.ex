defmodule FracomexWeb.UsersController do
  use FracomexWeb, :controller
  alias FracomexWeb.Router.Helpers, as: Routes
  alias Fracomex.Accounts
  alias Fracomex.Accounts.User
  alias Fracomex.Token
  alias Fracomex.UserEmail
  alias Fracomex.Products

  # VALIDATION DU FORMULAIRE DE VALIDATION DE MODIFICATION DE L'ADRESSE
  def edit_my_address(conn, %{"id" => id, "user" => user_params}) do
    # IO.inspect(user_params)
    user = Accounts.get_user_with_city!(id)
    changeset = Accounts.change_user(%User{})
    cities = Accounts.list_cities
      |> Enum.sort_by(&(&1.name))
      |> Enum.map(fn city -> [key: city.name, value: city.id] end)

    case Accounts.edit_oneself_address(user, user_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "my_address.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), user: user, cities: cities, changeset: changeset, edit_succesful: false, there_is_error: true)
      {:ok, user} ->
        user_with_city = Accounts.get_user_with_city!(user.id)
        render(conn, "my_address.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), user: user_with_city, cities: cities, changeset: changeset, edit_succesful: true, there_is_error: false)
    end
  end

  # VALIDATION DU FORMULAIRE DE MODIFICATION DU PROFIL PAR L'UTILISATEUR
  def edit_my_account(conn, %{"id" => id, "user" => user_params}) do
    changeset = Accounts.change_user(%User{})
    user = Accounts.get_user!(id)

    # IO.inspect Accounts.edit_oneself(user, user_params)

    case Accounts.edit_oneself(user, user_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        there_is_password_error = cond do
          is_nil(changeset.errors[:password]) and is_nil(changeset.errors[:current_password]) and is_nil(changeset.errors[:password_confirmation]) ->
            false
          true ->
            true
        end
        render(conn, "my_account.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), user: user, changeset: changeset, there_is_password_error: there_is_password_error, edit_succesful: false)
      {:ok, user} ->
        render(conn, "my_account.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), user: user, changeset: changeset, there_is_password_error: false, edit_succesful: true)
    end

  end
  #page mon compte
  def my_account(conn, _params) do
    cond do
      is_nil(get_session(conn, :user_id)) ->
        redirect(conn, to: "/connexion")
      true ->
        user_id = get_session(conn, :user_id)
        user = Accounts.get_user!(user_id)
        changeset = Accounts.change_user(%User{})
        render(conn, "my_account.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), user: user, changeset: changeset, there_is_password_error: false, edit_succesful: false)
    end
  end

  #page adresse
  def my_address(conn, _params) do

    cond do
      is_nil(get_session(conn, :user_id)) ->
        redirect(conn, to: "/connexion")
      true ->
        user_id = get_session(conn, :user_id)
        user = Accounts.get_user_with_city!(user_id)
        changeset = Accounts.change_user(%User{})
        cities = Accounts.list_cities
          |> Enum.sort_by(&(&1.name))
          |> Enum.map(fn city -> [key: city.name, value: city.id] end)
        render(conn, "my_address.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), user: user, cities: cities,changeset: changeset, edit_succesful: false, there_is_error: false)
    end

  end

  def my_orders(conn, _params) do

    cond do
      is_nil(get_session(conn, :user_id)) ->
        redirect(conn, to: "/connexion")
      true ->
        user_id = get_session(conn, :user_id)
        my_orders = Products.list_my_orders(user_id)
        render(conn, "my_orders.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), user: Accounts.get_user!(user_id), orders: my_orders)
    end

  end

  # def index(conn, _params) do
  #   render(conn, "signin.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  # end

  # Page de connexion
  def signin(conn, _params) do
    changeset = Accounts.change_user(%User{})
    cond do
      is_nil(get_session(conn, :user_id)) ->
        render(conn, "signin.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset)
      true ->
        # IO.inspect(conn)
        conn
        |> redirect(to: "/mon-profil")
    end
  end

  # Page d'inscription
  def signup(conn, _params) do

    # Génération du changeset neutre pour User et liste des pays et villes sur le formulaire
    changeset = Accounts.change_user(%User{})
    countries = Accounts.list_countries
                |> Enum.map(fn country -> [key: country.name, value: country.id] end)
    cities = Accounts.list_cities
                |> Enum.sort_by(&(&1.name))
                |> Enum.map(fn city -> [key: city.name, value: city.id] end)

    render(conn, "signup.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset, countries: countries, cities: cities)
  end

  def signout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> redirect(to: "/")
  end

  # Validation de formulaire d'inscription avec envoi de mail de confirmation
  def submit_signup(conn, %{"user" => user_params}) do
    # IO.inspect user_params

    countries = Accounts.list_countries
                |> Enum.map(fn country -> [key: country.name, value: country.id] end)
    cities = Accounts.list_cities
                |> Enum.sort_by(&(&1.name))
                |> Enum.map(fn city -> [key: city.name, value: city.id] end)

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        token = Token.generate_new_account_token(user.id)
        check_mail_url = "#{FracomexWeb.Endpoint.url()}#{Routes.users_path(conn, :check_signup_mail, token: token)}"
        UserEmail.send_check_signup_mail(check_mail_url, user.mail_address)
        conn
        |> render("signup_mail_sent.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "signup.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset, countries: countries, cities: cities)
    end
  end

  # Validation de formulaire de connexion
  def submit_signin(conn, %{"user" => user_params}) do
    # IO.inspect(user_params)
    case Accounts.signin_user(user_params) do
      {:error, changeset} ->
        # IO.inspect(changeset)
        render(conn, "signin.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset)
      _ ->
        id = Accounts.get_user_by_mail_address!(user_params["mail_address"]).id
        cart = Plug.Conn.get_session(conn, :cart)
        sum_cart = Plug.Conn.get_session(conn, :sum_cart)

        # METTRE A JOUR L'ID DE L'UTILISATEUR POUR LA COMMANDE ACTUELLE

        current_order_id = get_session(conn, :current_order)

        if not is_nil(current_order_id) do
          current_order = Products.get_order(current_order_id)
          Products.update_order_with_lines_with_user_id(current_order, id)
        end

        # |> put_session(:current_order, order.id)
        conn
        |> put_session(:user_id, id)
        |> put_session(:cart, cart)
        |> put_session(:sum_cart, sum_cart)
        |> redirect(to: "/boutique")
    end
  end

  # Redirection après la vérification de l'adresse email de l'utilisateur récemment inscrit
  def check_signup_mail(conn, %{"token" => token}) do
    # IO.inspect(token)

    with  {:ok, user_id} <- Fracomex.Token.verify_new_account_token(token) do
      # IO.inspect(user_id)
      Accounts.validate_user(Accounts.get_user!(user_id))
      render(conn, "valid_signup_token.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart))
    else
      _ -> render(conn, "invalid_signup_token.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart))
    end

  end

  # Formulaire pour mot de passe oublié
  def forgot_password(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "forgot_password.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset)
  end

  # Envoi de l'adresse mail de mot de passe oublié de l'utilisateur
  def submit_forgotten_password(conn, %{"user" => user_params}) do

    case Accounts.forgot_password(user_params) do
      {:error, changeset} ->
        # IO.inspect(changeset)
        render(conn, "forgot_password.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset)
      _ ->
        user = Accounts.get_user_by_mail_address!(user_params["mail_address"])
        token = Token.generate_new_account_token(user.id)
        forgot_password_mail_url = "#{FracomexWeb.Endpoint.url()}#{Routes.users_path(conn, :check_forgotten_password_mail, token: token)}"
        UserEmail.send_forgotten_password_mail(forgot_password_mail_url, user.mail_address)
        render(conn, "forgot_password_mail_sent.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart))
    end

  end

  # LIEN VERS LE FORMULAIRE DE MODIFICATION DU MOT DE PASSE OUBLIÉ
  def check_forgotten_password_mail(conn, %{"token" => token}) do
    with  {:ok, user_id} <- Fracomex.Token.verify_new_account_token(token) do
      # IO.inspect(user_id)
      changeset = Accounts.change_user(%User{})
      render(conn, "update_forgotten_password.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset, user_id: user_id)
    else
      _ -> render(conn, "invalid_forgotten_password_token.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart))
    end
  end

  # VALIDATION DU FORMULAIRE DE MODIFICATION DE MOT DE PASSE OUBLIÉ
  def submit_new_password_forgotten(conn, %{"id" => id, "user" => user_params}) do
    {user_id, _} = Integer.parse(id)

    user = Accounts.get_user!(user_id)
    case Accounts.update_new_password_forgotten_user(user, user_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "update_forgotten_password.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset, user_id: user_id)
      _ ->
        render(conn, "valid_forgotten_password_token.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart))
    end
  end

  # FORMULAIRE DE RENVOI DE CONFIRMATION DU MAIL
  def resend_confirmation_mail(conn, _params) do
    cond do
      not is_nil(get_session(conn, :user_id)) ->
        redirect(conn, to: "/mon-profil")

      true ->
        changeset = Accounts.change_user(%User{})
        render(conn, "resend_confirmation_mail.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset)
    end
  end

  def submit_resend_confirmation_mail(conn, %{"user" => user_params}) do

    case Accounts.resend_confirmation_mail(user_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "resend_confirmation_mail.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart), changeset: changeset)
      _ ->
        user = Accounts.get_user_by_mail_address!(user_params["mail_address"])
        token = Token.generate_new_account_token(user.id)
        check_mail_url = "#{FracomexWeb.Endpoint.url()}#{Routes.users_path(conn, :check_signup_mail, token: token)}"
        UserEmail.send_check_signup_mail(check_mail_url, user.mail_address)
        render(conn, "signup_mail_sent.html", cart: Plug.Conn.get_session(conn, :cart), selected_family_id: Plug.Conn.get_session(conn, :selected_family_id), sum_cart: Plug.Conn.get_session(conn, :sum_cart))
      end

  end

end
