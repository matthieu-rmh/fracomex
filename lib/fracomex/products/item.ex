defmodule Fracomex.Products.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fracomex.Products
  alias Fracomex.Products.{Family, Subfamily}

  @primary_key {:id, :string, autogenerate: false}
  schema "items" do
    field :caption, :string
    field :sale_price_vat_excluded, :decimal
    field :image, :string
    field :image_version, :integer
    field :real_stock, :decimal
    field :stock_status, :boolean, default: false
    field :is_published, :boolean, default: true

    # field :family_id, :string
    # field :sub_family_id, :string
    belongs_to :family, Family, type: :string
    belongs_to :sub_family, Subfamily, type: :string
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:caption, :sale_price_vat_excluded, :image, :image_version, :real_stock, :stock_status, :family_id, :sub_family_id])
    |> validate_required([:caption, :sale_price_vat_excluded, :image, :image_version, :real_stock, :stock_status, :family_id, :sub_family_id])
  end

  def update_changeset_without_image(item, attrs) do
    item
    |> cast(attrs, [:caption, :sale_price_vat_excluded, :real_stock, :stock_status, :family_id, :sub_family_id])
    |> check_family_id()
    |> check_subfamily_id()
  end

  def update_changeset_with_image(item, attrs) do
    item
    |> cast(attrs, [:image_version, :image ])
  end

  defp check_family_id(changeset) do

    cond do
      (not is_nil(get_change(changeset, :family_id))) and (get_change(changeset, :family_id) not in Products.list_family_ids())->
        add_error(changeset, :family_id, "Famille non inclus dans la base")
      true ->
        changeset
    end

  end

  defp check_subfamily_id(changeset) do

    cond do
      (not is_nil(get_change(changeset, :sub_family_id))) and (get_change(changeset, :sub_family_id) not in Products.list_sub_family_ids())->
        add_error(changeset, :sub_family_id, "Sous-famille non inclus dans la base")
      true ->
        changeset
    end

  end


end
