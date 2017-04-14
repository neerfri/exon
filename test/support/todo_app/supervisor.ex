defmodule TodoApp.Supervisor do
  def start_link do
    import Supervisor.Spec
    children = [
      supervisor(TodoApp.Repo, []),
      TodoApp.EventBus.child_spec
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
