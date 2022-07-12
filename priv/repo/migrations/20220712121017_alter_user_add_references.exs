defmodule Fracomex.Repo.Migrations.AlterUserAddReferences do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :country_id, references("countries")
      add :city_id, references("cities")
    end
  end
end
