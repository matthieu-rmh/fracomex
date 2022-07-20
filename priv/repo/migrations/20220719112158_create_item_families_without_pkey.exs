defmodule Fracomex.Repo.Migrations.CreateItemFamiliesWithoutPkey do
  use Ecto.Migration

  def change do
    create table(:item_families, primary: false) do
      add :item_family_id, :string, primary_key: true
      add :caption, :string
    end
  end
end
