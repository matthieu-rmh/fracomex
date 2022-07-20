defmodule Fracomex.Repo.Migrations.DropItemFamilies do
  use Ecto.Migration

  def change do
    drop table("item_families")
  end
end
