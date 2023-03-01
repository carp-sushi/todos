defmodule Todos.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :string, size: 12, primary_key: true
      add :list_id, references(:lists, type: :string), size: 12, null: false
      add :name, :string, null: false
    end
  end
end
