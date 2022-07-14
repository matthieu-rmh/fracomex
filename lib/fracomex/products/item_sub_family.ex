defmodule Fracomex.Products.ItemSubFamily do
  use Ecto.Schema
  import Ecto.Changeset

  schema "item_sub_families" do
    field :item_sub_family_id, :string
    field :caption, :string
    field :item_family_id, :string

    timestamps()
  end

  @doc false
  def changeset(item_sub_family, attrs) do
    item_sub_family
    |> cast(attrs, [:item_sub_family_id, :caption, :item_family_id])
    |> validate_required([:item_sub_family_id, :caption, :item_family_id])
  end
end
