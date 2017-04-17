defmodule TodoApp do
  use Exon.CommandGateway

  middleware Exon.Ecto.AggregateMiddleware, repo: TodoApp.Repo
  middleware Exon.EventBus.Middleware, event_bus: TodoApp.EventBus

  commands_from TodoApp.TodoList
end
