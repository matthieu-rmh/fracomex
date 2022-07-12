defmodule FracomexWeb.UsersController do
  use FracomexWeb, :controller
  alias Fracomex.Accounts
  alias Fracomex.Accounts.{User, Country, City}

  def index(conn, _params) do
    render(conn, "signin.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  # Page de connexion
  def signin(conn, _params) do
    render(conn, "signin.html", layout: {FracomexWeb.LayoutView, "layout.html"})
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

    render(conn, "signup.html", changeset: changeset, countries: countries, cities: cities, layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  # Validation de formulaire d'inscription
  def submit_signup(conn, %{"user" => user_params}) do
    IO.inspect user_params

    countries = Accounts.list_countries
                |> Enum.map(fn country -> [key: country.name, value: country.id] end)
    cities = Accounts.list_cities
                |> Enum.sort_by(&(&1.name))
                |> Enum.map(fn city -> [key: city.name, value: city.id] end)

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        render(conn, "signup.html", changeset: changeset, countries: countries, cities: cities, layout: {FracomexWeb.LayoutView, "layout.html"})
    end
  end
end
