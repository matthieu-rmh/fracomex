defmodule Fracomex.Repo.Migrations.AlterItemAddIsPublished do
  use Ecto.Migration

  def change do
    alter table("items") do
      add :is_published, :boolean
    end
  end
end
