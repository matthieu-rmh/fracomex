defmodule Fracomex.Repo.Migrations.CreateOrderLines do
  use Ecto.Migration

  def change do
    create table(:order_lines) do
      add :order_id, references("orders", type: :string)
      add :item_id, references("items", type: :string)
      add :user_id, references("users")
      add :quantity, :integer

      timestamps()
    end
  end
end
