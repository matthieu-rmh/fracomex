defmodule Fracomex.Products.ItemSubFamily do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fracomex.Products

  @primary_key {:item_sub_family_id, :string, autogenerate: false}
  schema "item_sub_families" do
    field :caption, :string
    field :item_family_id, :string
  end

  @doc false
  def changeset(item_sub_family, attrs) do
    item_sub_family
    |> cast(attrs, [:item_sub_family_id, :caption, :item_family_id])
    |> validate_required([:item_sub_family_id, :caption, :item_family_id])
  end

  def update_changeset(item_sub_family, attrs) do
    item_sub_family
    |> cast(attrs, [:caption, :item_family_id])
    |> check_item_family_change()
  end

  defp check_item_family_change(changeset) do
    item_family_id = get_change(changeset, :item_family_id)
    local_item_family_ids = Products.list_item_family_ids()
    cond do
      not is_nil(item_family_id) and (item_family_id not in local_item_family_ids) ->
        add_error(changeset, :invalid_item_family, "sous-famille invalide")
      true ->
        changeset
    end
  end
end
