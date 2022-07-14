defmodule Fracomex.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :item_id, :string
      add :caption, :string
      add :sale_price_vat_excluded, :decimal
      add :item_image, :string
      add :image_version, :integer
      add :real_stock, :decimal
      add :stock_status, :boolean, default: false
      add :item_family_id, :string
      add :item_sub_family_id, :string

      timestamps()
    end
  end
end
