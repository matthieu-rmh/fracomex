defmodule Fracomex.Products.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "items" do
    field :caption, :string
    field :sale_price_vat_excluded, :decimal
    field :image, :string
    field :image_version, :integer
    field :real_stock, :decimal
    field :stock_status, :boolean, default: false
    field :family_id, :string
    field :sub_family_id, :string
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:caption, :sale_price_vat_excluded, :image, :image_version, :real_stock, :stock_status, :family_id, :sub_family_id])
    |> validate_required([:caption, :sale_price_vat_excluded, :image, :image_version, :real_stock, :stock_status, :family_id, :sub_family_id])
  end
end
