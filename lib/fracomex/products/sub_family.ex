defmodule Fracomex.Products.SubFamily do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fracomex.Products

  @primary_key {:id, :string, autogenerate: false}
  schema "sub_families" do
    field :caption, :string
    field :family_id, :string
  end

  @doc false
  def changeset(sub_family, attrs) do
    sub_family
    |> cast(attrs, [:id, :caption, :family_id])
    |> validate_required([:id, :caption, :family_id])
  end

  def update_changeset(sub_family, attrs) do
    sub_family
    |> cast(attrs, [:caption, :family_id])
    |> check_item_family_change()
  end

  defp check_item_family_change(changeset) do
    family_id = get_change(changeset, :family_id)
    local_family_ids = Products.list_family_ids()
    cond do
      not is_nil(family_id) and (family_id not in local_family_ids) ->
        add_error(changeset, :invalid_item_family, "sous-famille invalide")
      true ->
        changeset
    end
  end


end
