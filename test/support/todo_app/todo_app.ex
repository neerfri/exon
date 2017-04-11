defmodule TodoApp do
  use Exon.CommandGateway

  middleware Exon.Middleware.EctoAggregate, repo: TodoApp.Repo
  middleware Exon.Middleware.ExonEventBus, event_bus: TodoApp.EventBus

  commands_from TodoApp.TodoList
end
