defmodule Fracomex.Products.Family do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fracomex.Products.{SubFamily, Item}

  @primary_key {:id, :string, autogenerate: false}
  schema "families" do
    field :caption, :string
    has_many :sub_families, SubFamily
    has_many :items, Item
  end

  @doc false
  def changeset(family, attrs) do
    family
    |> cast(attrs, [:id, :caption])
    |> validate_required([:id, :caption])
  end

  def update_changeset(family, attrs) do
    family
    |> cast(attrs, [:caption])
  end
end
