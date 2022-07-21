defmodule Fracomex.Repo.Migrations.CreateItemSubFamiliesWithoutPkey do
  use Ecto.Migration

  def change do
    create table(:item_sub_families, primary: false) do
      add :item_sub_family_id, :string, primary_key: true
      add :caption, :string
      add :item_family_id, references("item_families", column: :item_family_id, type: :string)
    end
  end

end
