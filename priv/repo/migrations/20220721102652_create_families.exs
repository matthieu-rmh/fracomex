defmodule Fracomex.Repo.Migrations.CreateFamilies do
  use Ecto.Migration

  def change do
    create table(:families, primary_key: false) do
      add :id, :string, primary_key: true
      add :caption, :string
    end
  end
end
