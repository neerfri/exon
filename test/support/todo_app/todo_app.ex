defmodule TodoApp do
  use Exon.CommandGateway, repo: TodoApp.Repo

  commands_from TodoApp.TodoList
end
