defmodule Fracomex.Products.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :item_id, :string
    field :caption, :string
    field :sale_price_vat_excluded, :decimal
    field :item_image, :string
    field :image_version, :integer
    field :real_stock, :decimal
    field :stock_status, :boolean, default: false
    field :item_family_id, :string
    field :item_sub_family_id, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:item_id, :caption, :sale_price_vat_excluded, :item_image, :image_version, :real_stock, :stock_status, :item_family_id, :item_sub_family_id])
    |> validate_required([:item_id, :caption, :sale_price_vat_excluded, :item_image, :image_version, :real_stock, :stock_status, :item_family_id, :item_sub_family_id])
  end
end
