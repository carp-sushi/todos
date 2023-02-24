defmodule Todos.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :list_id, references(:lists, type: :uuid), null: false
      add :name, :string, null: false
    end
  end
end
