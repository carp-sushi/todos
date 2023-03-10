defmodule Todos.List do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:id, :name, :items]}
  @primary_key {:id, :string, autogenerate: {Ecto.Nanoid, :autogenerate, []}}
  schema "lists" do
    field(:name, :string)
    has_many(:items, Todos.Item)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
  end

  def create(name) do
    %Todos.List{}
    |> changeset(%{:name => name})
    |> Todos.Repo.insert()
  end

  def update(id, name) do
    %Todos.List{id: id}
    |> changeset(%{:name => name})
    |> Todos.Repo.update()
  end
end
