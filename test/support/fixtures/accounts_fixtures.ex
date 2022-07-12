defmodule Fracomex.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fracomex.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        city: "some city",
        country: "some country",
        firstname: "some firstname",
        mail_address: "some mail_address",
        name: "some name",
        password: "some password",
        phone_number: "some phone_number",
        street: "some street",
        zipcode: "some zipcode"
      })
      |> Fracomex.Accounts.create_user()

    user
  end

  @doc """
  Generate a country.
  """
  def country_fixture(attrs \\ %{}) do
    {:ok, country} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Fracomex.Accounts.create_country()

    country
  end

  @doc """
  Generate a city.
  """
  def city_fixture(attrs \\ %{}) do
    {:ok, city} =
      attrs
      |> Enum.into(%{
        name: "some name",
        zipcode: "some zipcode"
      })
      |> Fracomex.Accounts.create_city()

    city
  end
end
