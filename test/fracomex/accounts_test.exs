defmodule Fracomex.AccountsTest do
  use Fracomex.DataCase

  alias Fracomex.Accounts

  describe "users" do
    alias Fracomex.Accounts.User

    import Fracomex.AccountsFixtures

    @invalid_attrs %{city: nil, country: nil, firstname: nil, mail_address: nil, name: nil, password: nil, phone_number: nil, street: nil, zipcode: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{city: "some city", country: "some country", firstname: "some firstname", mail_address: "some mail_address", name: "some name", password: "some password", phone_number: "some phone_number", street: "some street", zipcode: "some zipcode"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.city == "some city"
      assert user.country == "some country"
      assert user.firstname == "some firstname"
      assert user.mail_address == "some mail_address"
      assert user.name == "some name"
      assert user.password == "some password"
      assert user.phone_number == "some phone_number"
      assert user.street == "some street"
      assert user.zipcode == "some zipcode"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{city: "some updated city", country: "some updated country", firstname: "some updated firstname", mail_address: "some updated mail_address", name: "some updated name", password: "some updated password", phone_number: "some updated phone_number", street: "some updated street", zipcode: "some updated zipcode"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.city == "some updated city"
      assert user.country == "some updated country"
      assert user.firstname == "some updated firstname"
      assert user.mail_address == "some updated mail_address"
      assert user.name == "some updated name"
      assert user.password == "some updated password"
      assert user.phone_number == "some updated phone_number"
      assert user.street == "some updated street"
      assert user.zipcode == "some updated zipcode"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "countries" do
    alias Fracomex.Accounts.Country

    import Fracomex.AccountsFixtures

    @invalid_attrs %{name: nil}

    test "list_countries/0 returns all countries" do
      country = country_fixture()
      assert Accounts.list_countries() == [country]
    end

    test "get_country!/1 returns the country with given id" do
      country = country_fixture()
      assert Accounts.get_country!(country.id) == country
    end

    test "create_country/1 with valid data creates a country" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Country{} = country} = Accounts.create_country(valid_attrs)
      assert country.name == "some name"
    end

    test "create_country/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_country(@invalid_attrs)
    end

    test "update_country/2 with valid data updates the country" do
      country = country_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Country{} = country} = Accounts.update_country(country, update_attrs)
      assert country.name == "some updated name"
    end

    test "update_country/2 with invalid data returns error changeset" do
      country = country_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_country(country, @invalid_attrs)
      assert country == Accounts.get_country!(country.id)
    end

    test "delete_country/1 deletes the country" do
      country = country_fixture()
      assert {:ok, %Country{}} = Accounts.delete_country(country)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_country!(country.id) end
    end

    test "change_country/1 returns a country changeset" do
      country = country_fixture()
      assert %Ecto.Changeset{} = Accounts.change_country(country)
    end
  end

  describe "cities" do
    alias Fracomex.Accounts.City

    import Fracomex.AccountsFixtures

    @invalid_attrs %{name: nil, zipcode: nil}

    test "list_cities/0 returns all cities" do
      city = city_fixture()
      assert Accounts.list_cities() == [city]
    end

    test "get_city!/1 returns the city with given id" do
      city = city_fixture()
      assert Accounts.get_city!(city.id) == city
    end

    test "create_city/1 with valid data creates a city" do
      valid_attrs = %{name: "some name", zipcode: "some zipcode"}

      assert {:ok, %City{} = city} = Accounts.create_city(valid_attrs)
      assert city.name == "some name"
      assert city.zipcode == "some zipcode"
    end

    test "create_city/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_city(@invalid_attrs)
    end

    test "update_city/2 with valid data updates the city" do
      city = city_fixture()
      update_attrs = %{name: "some updated name", zipcode: "some updated zipcode"}

      assert {:ok, %City{} = city} = Accounts.update_city(city, update_attrs)
      assert city.name == "some updated name"
      assert city.zipcode == "some updated zipcode"
    end

    test "update_city/2 with invalid data returns error changeset" do
      city = city_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_city(city, @invalid_attrs)
      assert city == Accounts.get_city!(city.id)
    end

    test "delete_city/1 deletes the city" do
      city = city_fixture()
      assert {:ok, %City{}} = Accounts.delete_city(city)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_city!(city.id) end
    end

    test "change_city/1 returns a city changeset" do
      city = city_fixture()
      assert %Ecto.Changeset{} = Accounts.change_city(city)
    end
  end
end
