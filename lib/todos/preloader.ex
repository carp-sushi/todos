defmodule Todos.Preloader do
  import Plug.Conn
  alias Todos.Repo, as: R
  require Logger

  def init(opts), do: opts

  def call(%Plug.Conn{path_info: ["todos", id | _], method: "GET"} = conn, _opts) do
    todo = R.get(Todos.List, id)

    if is_nil(todo) do
      %{:error => "todo list not found: #{id}"}
      |> encode_json()
      |> send_404(conn)
    end

    Logger.info("Pre-loaded todo list: #{id}")
    conn |> assign(:list, todo)
  end

  def call(conn, _opts) do
    # IO.inspect(conn, label: "conn")
    conn
  end

  # Encode data as JSON.
  defp encode_json(data), do: Poison.encode!(data)

  # Send a JSON response.
  defp send_404(resp, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, resp)
    |> halt
  end
end
