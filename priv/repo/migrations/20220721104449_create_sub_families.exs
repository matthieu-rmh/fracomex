defmodule Fracomex.Repo.Migrations.CreateSubFamilies do
  use Ecto.Migration

  def change do
    create table(:sub_families, primary_key: false) do
      add :id, :string, primary_key: true
      add :caption, :string
      add :family_id, references("families", type: :string, on_delete: :delete_all)
    end
  end
end
