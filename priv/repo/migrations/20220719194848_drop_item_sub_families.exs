defmodule Fracomex.Repo.Migrations.DropItemSubFamilies do
  use Ecto.Migration

  def change do
    drop table("item_sub_families")
  end
end
