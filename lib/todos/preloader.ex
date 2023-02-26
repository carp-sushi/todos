defmodule Todos.Preloader do
  import Plug.Conn
  alias Todos.Repo, as: R
  require Logger

  def init(opts), do: opts

  def call(%Plug.Conn{path_info: ["todos", id | _]} = conn, _opts) do
    list = R.get(Todos.List, id)

    if is_nil(list) do
      %{:error => "todo list not found: #{id}"}
      |> send_404(conn)
    else
      Logger.info("Loaded todo list: #{id}")
      conn |> assign(:list, list)
    end
  end

  def call(conn, _opts), do: conn

  # Send a JSON response.
  defp send_404(data, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Poison.encode!(data))
    |> halt
  end
end
