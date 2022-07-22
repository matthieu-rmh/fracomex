defmodule Fracomex.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :string, primary_key: true
      add :caption, :string
      add :sale_price_vat_excluded, :decimal
      add :image, :string
      add :image_version, :integer
      add :real_stock, :decimal
      add :stock_status, :boolean, default: false
      add :family_id, references("families", type: :string, on_delete: :nilify_all)
      add :sub_family_id, references("sub_families", type: :string, on_delete: :nilify_all)
    end
  end
end
