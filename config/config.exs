use Mix.Config

config :exon, ecto_repos: [TodoApp.Repo]

config :exon, TodoApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  priv: "priv/todo_app/repo",
  database: "exon_todo_app",
  hostname: "localhost",
  username: "postgres",
  password: "postgres"
