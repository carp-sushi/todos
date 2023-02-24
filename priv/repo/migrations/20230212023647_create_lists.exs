defmodule Todos.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string, null: false
    end
  end
end
