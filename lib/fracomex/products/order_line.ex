defmodule Fracomex.Products.OrderLine do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fracomex.Utilities
  alias Fracomex.Products.Item
  # alias Fracomex.Accounts.User

  schema "order_lines" do
    field :order_id, :string
    # field :item_id, :string
    field :user_id, :integer
    field :quantity, :integer
    belongs_to :item, Item, type: :string
    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_id, :item_id, :user_id, :quantity])
  end

  def create_changeset(order, attrs) do
    order
    |> cast(attrs, [:order_id, :item_id, :user_id, :quantity])
    |> put_default_fields()
  end

  defp put_default_fields(changeset) do
    changeset
    |> put_change(:inserted_at, Utilities.get_remote_naive_date)
    |> put_change(:updated_at, Utilities.get_remote_naive_date)
  end

end
