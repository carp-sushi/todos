defmodule Todos.List do
  use Ecto.Schema
  alias Todos.{Repo, List, Item}
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @derive {Poison.Encoder, only: [:id, :name, :items]}
  schema "lists" do
    field(:name, :string)
    has_many(:items, Item)
  end

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

  def update(id, name) do
    %List{id: id}
    |> changeset(%{:name => name})
    |> Repo.update()
  end
end
