defmodule TodosTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Todos.Router.init([])

  test "it returns 200 on status check" do
    req = conn(:get, "/status")
    res = Todos.Router.call(req, @opts)
    assert res.status == 200
  end

  test "it returns 404 when no route matches" do
    req = conn(:get, "/fail")
    res = Todos.Router.call(req, @opts)
    assert res.status == 404
  end
end
