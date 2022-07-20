defmodule Fracomex.Repo.Migrations.AddUniqueIndexToItemSubFamilies do
  use Ecto.Migration

  def change do
    create unique_index(:item_sub_families, [:item_sub_family_id])
  end
end
