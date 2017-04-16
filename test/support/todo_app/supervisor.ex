defmodule TodoApp.Supervisor do
  def start_link do
    import Supervisor.Spec
    children = [
      supervisor(TodoApp.Repo, []),
      worker(TodoApp.EventBus, []),
      worker(TodoApp.EventHandler, [[event_bus: TodoApp.EventBus]])
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
