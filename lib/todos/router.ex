defmodule Todos.Router do
  use Plug.Router
  alias Todos.Repo

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(Todos.Preloader)
  plug(:dispatch)

  @ok 200
  @no_content 204
  @bad_request 400
  @not_found 404

  # Send a JSON response.
  defp send_json(data, conn, status \\ @ok) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(data))
  end

  # Sends a JSON error response
  defp send_json_err(msg, conn, status) do
    %{error: msg} |> send_json(conn, status)
  end

  # Helper function that extracts a name field from a JSON request body.
  defp name_param(conn) do
    case conn.body_params do
      %{"name" => name} -> name
      _ -> ""
    end
  end

  # Handle the successful result of creating or updating a todo list/item.
  defp handle_save(conn, {:ok, todo}),
    do: send_json(%{id: todo.id, name: todo.name}, conn)

  # Handle the failed result of a change set.
  defp handle_save(conn, {:error, cs}),
    do: send_json(Todos.Error.extract(cs), conn, @bad_request)

  # Send all todo lists as JSON.
  get "/todos" do
    Repo.all(Todos.List)
    |> Enum.map(fn l -> %{id: l.id, name: l.name} end)
    |> send_json(conn)
  end

  # Send a todo list as JSON.
  get "/todos/:id" do
    send_json(
      Repo.preload(conn.assigns.list, [:items]),
      conn
    )
  end

  # Create a new todo list
  post "/todos" do
    handle_save(
      conn,
      Todos.List.create(name_param(conn))
    )
  end

  # Update a todo list name.
  put "/todos/:id" do
    handle_save(
      conn,
      Todos.List.update(conn.assigns.list.id, name_param(conn))
    )
  end

  # Delete an empty todo list.
  delete "/todos/:id" do
    list = Repo.preload(conn.assigns.list, [:items])

    if length(list.items) > 0 do
      send_json_err("todo list has items: #{id}", conn, @bad_request)
    else
      Repo.delete(list)
      send_resp(conn, @no_content, "")
    end
  end

  # Add a new item to a todo list
  post "/todos/:id/items" do
    handle_save(
      conn,
      Todos.Item.create(conn.assigns.list.id, name_param(conn))
    )
  end

  # Update a todo list item
  put "/todos/:list_id/items/:item_id" do
    item = Repo.get(Todos.Item, item_id)

    case validate_list_item(conn.assigns.list, item, item_id) do
      {:error, msg, status} ->
        send_json_err(msg, conn, status)

      {:ok} ->
        handle_save(
          conn,
          Todos.Item.update(item.id, name_param(conn))
        )
    end
  end

  # Delete a todo list item
  delete "/todos/:list_id/items/:item_id" do
    item = Repo.get(Todos.Item, item_id)

    case validate_list_item(conn.assigns.list, item, item_id) do
      {:error, msg, status} ->
        send_json_err(msg, conn, status)

      {:ok} ->
        Repo.delete(item)
        send_resp(conn, @no_content, "")
    end
  end

  # Validate that an item is an element of a todo list.
  defp validate_list_item(list, item, item_id) do
    cond do
      is_nil(item) ->
        {:error, "todo list item not found: #{item_id}", @not_found}

      list.id != item.list_id ->
        {:error, "item not an element of todo list: #{list.id}", @bad_request}

      true ->
        {:ok}
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
