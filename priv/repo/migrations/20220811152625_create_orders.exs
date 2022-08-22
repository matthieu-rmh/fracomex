defmodule Fracomex.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :string, primary_key: true
      add :user_id, references("users")
      add :sum, :decimal
      add :checked_out, :boolean
      timestamps()
    end
  end
end
