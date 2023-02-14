defmodule Todos.List do
  use Ecto.Schema
  alias Todos.{Repo, List, Item}
  import Ecto.Changeset

  schema "lists" do
    field(:name, :string)
    has_many(:items, Todos.Item)
  end

  def fields(list),
    do: %{:id => list.id, :name => list.name}

  def all_fields(list),
    do: %{
      :id => list.id,
      :name => list.name,
      :items => Enum.map(list.items, &Item.fields(&1))
    }

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
  end

  def create(name) do
    %List{}
    |> changeset(%{:name => name})
    |> Repo.insert()
  end
end
