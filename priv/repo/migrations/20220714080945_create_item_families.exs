defmodule Fracomex.Repo.Migrations.CreateItemFamilies do
  use Ecto.Migration

  def change do
    create table(:item_families) do
      add :item_family_id, :string
      add :caption, :string

      timestamps()
    end
  end
end
