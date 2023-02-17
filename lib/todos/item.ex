defmodule Todos.Item do
  use Ecto.Schema
  alias Todos.{Repo, Item}
  import Ecto.Changeset

  schema "items" do
    field(:name, :string)
    belongs_to(:list, Todos.List)
  end

  def fields({:ok, item}), do: fields(item)

  def fields(item),
    do: %{:id => item.id, :name => item.name}

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
  end

  def create(id, name) do
    %Item{list_id: id}
    |> changeset(%{:name => name})
    |> Repo.insert()
  end

  def update(id, name) do
    %Item{id: id}
    |> changeset(%{:name => name})
    |> Repo.update()
  end
end
