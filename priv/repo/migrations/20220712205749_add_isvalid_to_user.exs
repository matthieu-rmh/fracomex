defmodule Fracomex.Repo.Migrations.AddIsvalidToUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :is_valid, :boolean, default: false
    end
  end
end
