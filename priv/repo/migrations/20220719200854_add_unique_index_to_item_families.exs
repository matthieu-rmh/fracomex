defmodule Fracomex.Repo.Migrations.AddUniqueIndexToItemFamilies do
  use Ecto.Migration

  def change do
    create unique_index(:item_families, [:item_family_id])
  end
end
