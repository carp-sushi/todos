defmodule Todos.Item do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Todos.{Repo, Item}

  @derive {Poison.Encoder, only: [:id, :name]}
  @primary_key {:id, :string, autogenerate: {Ecto.Nanoid, :autogenerate, []}}
  schema "items" do
    field(:name, :string)
    belongs_to(:list, Todos.List, type: Ecto.Nanoid)
  end

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
