defmodule TodoApp do
  use Exon.CommandGateway

  middleware Exon.Middleware.EctoAggregate, repo: TodoApp.Repo
  middleware Exon.Middleware.ExonEventBus, event_bus: TodoApp.EventBus

  commands_from TodoApp.TodoList

  def start_link do
    TodoApp.Repo.start_link
    TodoApp.EventBus.start_link
  end
end
