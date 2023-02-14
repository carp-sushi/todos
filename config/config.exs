import Config

config :todos, Todos.Repo,
  database: "todos",
  username: "todos",
  password: "todos",
  hostname: "localhost"

config :todos, ecto_repos: [Todos.Repo]
