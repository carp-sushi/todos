defmodule Todos.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :list_id, references(:lists), null: false
      add :name, :string, null: false
    end
  end
end
