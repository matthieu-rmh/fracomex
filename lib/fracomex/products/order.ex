defmodule Fracomex.Products.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fracomex.Utilities
  alias Fracomex.Products.OrderLine
  # alias Fracomex.Accounts.User

  @primary_key {:id, :string, autogenerate: false}
  schema "orders" do
    field :user_id, :integer
    field :sum, :decimal
    field :checked_out, :boolean
    has_many :order_lines, OrderLine
    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:id, :user_id, :sum, :checked_out])
  end

  def create_changeset(order, attrs) do
    order
    |> cast(attrs, [:id, :user_id, :sum, :checked_out])
    |> put_default_fields()
  end

  defp put_default_fields(changeset) do
    changeset
    |> put_change(:id, Utilities.generate_order_id)
    |> put_change(:checked_out, false)
    |> put_change(:inserted_at, Utilities.get_remote_naive_date)
    |> put_change(:updated_at, Utilities.get_remote_naive_date)
  end

end
