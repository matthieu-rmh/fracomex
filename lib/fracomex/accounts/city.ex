defmodule Fracomex.Accounts.City do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cities" do
    field :name, :string
    field :zipcode, :string

    timestamps()
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, [:name, :zipcode])
    |> validate_required([:name, :zipcode])
  end
end
