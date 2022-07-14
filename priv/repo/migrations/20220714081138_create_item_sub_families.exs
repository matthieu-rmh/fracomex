defmodule Fracomex.Repo.Migrations.CreateItemSubFamilies do
  use Ecto.Migration

  def change do
    create table(:item_sub_families) do
      add :item_sub_family_id, :string
      add :caption, :string
      add :item_family_id, :string

      timestamps()
    end
  end
end
