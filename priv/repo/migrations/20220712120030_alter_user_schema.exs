defmodule Fracomex.Repo.Migrations.AlterUserSchema do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove :country
      remove :city
      remove :zipcode
    end
  end
end
