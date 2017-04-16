defmodule TodoApp.Supervisor do
  def start_link do
    import Supervisor.Spec
    children = [
      supervisor(TodoApp.Repo, []),
      worker(TodoApp.EventBus, [event_handlers()]),
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp event_handlers do
    [TodoApp.EventHandler]
  end
end
