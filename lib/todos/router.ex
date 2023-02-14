defmodule Todos.Router do
  use Plug.Router
  alias Todos.Repo

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  @not_found 404
  @bad_request 400
  @ok 200

  # Encode data as JSON.
  defp encode_json(data) do
    Poison.encode!(data)
  end

  # Send a JSON response.
  defp send_json(resp, conn, status \\ @ok) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, resp)
  end

  # Send all todo lists as JSON.
  get "/todos" do
    Repo.all(Todos.List)
    |> Enum.map(&Todos.List.fields(&1))
    |> encode_json()
    |> send_json(conn)
  end

  # Send a todo list as JSON.
  get "/todos/:id" do
    list = Repo.preload(Repo.get(Todos.List, id), [:items])

    if is_nil(list) do
      %{:error => "todo list not found: #{id}"}
      |> encode_json()
      |> send_json(conn, @not_found)
    else
      Todos.List.all_fields(list)
      |> encode_json()
      |> send_json(conn)
    end
  end

  # Create a new todo list
  post "/todos" do
    result =
      case conn.body_params do
        %{"name" => name} -> Todos.List.create(name)
        _ -> {:body_error, "todo list name is required in request body"}
      end

    case result do
      {:ok, todo} ->
        Todos.List.fields(todo)
        |> encode_json()
        |> send_json(conn)

      {:body_error, errm} ->
        %{:error => errm}
        |> encode_json()
        |> send_json(conn, @bad_request)

      {:error, cs} ->
        Todos.Error.extract(cs)
        |> encode_json()
        |> send_json(conn, @bad_request)
    end
  end

  # Delete an empty todo list.
  delete "/todos/:id" do
    list = Repo.preload(Repo.get(Todos.List, id), [:items])

    cond do
      is_nil(list) ->
        %{:error => "todo list not found: #{id}"}
        |> encode_json()
        |> send_json(conn, @not_found)

      length(list.items) > 0 ->
        %{:error => "cannot delete todo list with items: #{id}"}
        |> encode_json()
        |> send_json(conn, @bad_request)

      true ->
        Repo.delete!(list)
        |> Todos.List.fields()
        |> encode_json()
        |> send_json(conn)
    end
  end

  # Add a new item to a todo list
  post "/todos/:id/items" do
    list = Repo.get(Todos.List, id)

    if is_nil(list) do
      %{:error => "todo list not found: #{id}"}
      |> encode_json()
      |> send_json(conn, @not_found)
    else
      result =
        case conn.body_params do
          %{"name" => name} -> Todos.Item.create(list.id, name)
          _ -> {:body_error, "item name is required in request body"}
        end

      case result do
        {:ok, item} ->
          Todos.Item.fields(item)
          |> encode_json()
          |> send_json(conn)

        {:body_error, errm} ->
          %{:error => errm}
          |> encode_json()
          |> send_json(conn, @bad_request)

        {:error, cs} ->
          Todos.Error.extract(cs)
          |> encode_json()
          |> send_json(conn, @bad_request)
      end
    end
  end

  # Delete a todo list item
  delete "/todos/:lid/items/:id" do
    list = Repo.get(Todos.List, lid)

    if is_nil(list) do
      %{:error => "todo list not found: #{lid}"}
      |> encode_json()
      |> send_json(conn, @not_found)
    else
      item = Repo.get(Todos.Item, id)

      cond do
        is_nil(item) ->
          %{:error => "todo list item not found: #{id}"}
          |> encode_json()
          |> send_json(conn, @not_found)

        list.id != item.list_id ->
          %{:error => "item not a member of todo list: #{lid}"}
          |> encode_json()
          |> send_json(conn, @bad_request)

        true ->
          Repo.delete(item)
          |> Todos.Item.fields()
          |> encode_json()
          |> send_json(conn)
      end
    end
  end

  # Render status
  get "/status" do
    send_resp(conn, @ok, "")
  end

  # catch-all sends a 404
  match _ do
    send_resp(conn, @not_found, "")
  end
end
