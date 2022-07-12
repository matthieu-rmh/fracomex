defmodule Fracomex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :firstname, :string
      add :mail_address, :string
      add :zipcode, :string
      add :street, :string
      add :country, :string
      add :phone_number, :string
      add :city, :string
      add :password, :string

      timestamps()
    end
  end
end
