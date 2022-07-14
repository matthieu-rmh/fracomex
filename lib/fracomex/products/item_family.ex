defmodule Fracomex.Products.ItemFamily do
  use Ecto.Schema
  import Ecto.Changeset

  schema "item_families" do
    field :item_family_id, :string
    field :caption, :string

    timestamps()
  end

  @doc false
  def changeset(item_family, attrs) do
    item_family
    |> cast(attrs, [:item_family_id, :caption])
    |> validate_required([:item_family_id, :caption])
  end
end
