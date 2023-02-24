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

  # Encode data as JSON.
  defp encode_json(data),
    do: Poison.encode!(data)

  # Send a JSON response.
  defp send_json(resp, conn, status \\ @ok) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, resp)
  end

  # Send all todo lists as JSON.
  get "/todos" do
    Repo.all(Todos.List)
    |> Enum.map(fn l -> %{:id => l.id, :name => l.name} end)
    |> encode_json()
    |> send_json(conn)
  end

  # Send a todo list as JSON.
  get "/todos/:id" do
    Repo.preload(conn.assigns[:list], [:items])
    |> encode_json()
    |> send_json(conn)
  end

  # Create a new todo list
  post "/todos" do
    handle_list_save(
      conn,
      case conn.body_params do
        %{"name" => name} -> Todos.List.create(name)
        _ -> {:body_error, "todo list name is required in request body"}
      end
    )
  end

  # Update a todo list name.
  put "/todos/:id" do
    list = conn.assigns[:list]

    handle_list_save(
      conn,
      case conn.body_params do
        %{"name" => name} -> Todos.List.update(list.id, name)
        _ -> {:body_error, "todo list name is required in request body"}
      end
    )
  end

  # Handle the successful result of creating or updating a todo list.
  def handle_list_save(conn, {:ok, todo}) do
    %{:id => todo.id, :name => todo.name}
    |> encode_json()
    |> send_json(conn)
  end

  # Handle a JSON body error.
  def handle_list_save(conn, {:body_error, errm}) do
    %{:error => errm}
    |> encode_json()
    |> send_json(conn, @bad_request)
  end

  # Handle the failed result of a change set.
  def handle_list_save(conn, {:error, cs}) do
    Todos.Error.extract(cs)
    |> encode_json()
    |> send_json(conn, @bad_request)
  end

  # Delete an empty todo list.
  delete "/todos/:id" do
    list = Repo.preload(conn.assigns[:list], [:items])

    if length(list.items) > 0 do
      %{:error => "todo list has items: #{id}"}
      |> encode_json()
      |> send_json(conn, @bad_request)
    else
      Repo.delete(list)
      send_resp(conn, @no_content, "")
    end
  end

  # Add a new item to a todo list
  post "/todos/:id/items" do
    list = conn.assigns[:list]

    handle_item_save(
      conn,
      case conn.body_params do
        %{"name" => name} -> Todos.Item.create(list.id, name)
        _ -> {:body_error, "item name is required in request body"}
      end
    )
  end

  # Update a todo list item
  put "/todos/:list_id/items/:item_id" do
    list = conn.assigns[:list]
    item = Repo.get(Todos.Item, item_id)

    case validate_list_item(list, item, item_id) do
      {:error, msg} ->
        %{:error => msg} |> encode_json() |> send_json(conn, @not_found)

      {:ok} ->
        handle_item_save(
          conn,
          case conn.body_params do
            %{"name" => name} -> Todos.Item.update(item.id, name)
            _ -> {:body_error, "item name is required in request body"}
          end
        )
    end
  end

  # Handle the successful result of creating or updating a todo list item.
  def handle_item_save(conn, {:ok, item}) do
    item
    |> encode_json()
    |> send_json(conn)
  end

  # Handle a JSON body error.
  def handle_item_save(conn, {:body_error, errm}) do
    %{:error => errm}
    |> encode_json()
    |> send_json(conn, @bad_request)
  end

  # Handle the failed result of a change set.
  def handle_item_save(conn, {:error, cs}) do
    Todos.Error.extract(cs)
    |> encode_json()
    |> send_json(conn, @bad_request)
  end

  # Delete a todo list item
  delete "/todos/:list_id/items/:item_id" do
    list = conn.assigns[:list]
    item = Repo.get(Todos.Item, item_id)

    case validate_list_item(list, item, item_id) do
      {:error, msg} ->
        %{:error => msg} |> encode_json() |> send_json(conn, @not_found)

      {:ok} ->
        Repo.delete(item)
        send_resp(conn, @no_content, "")
    end
  end

  # Validate that an item is a member of a todo list.
  def validate_list_item(list, item, item_id) do
    cond do
      is_nil(item) ->
        {:error, "todo list item not found: #{item_id}"}

      list.id != item.list_id ->
        {:error, "item not a member of todo list"}

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
