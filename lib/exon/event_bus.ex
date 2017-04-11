defmodule Exon.EventBus do
  defmacro __using__(_opts) do
    quote do
      import Exon.EventBus, only: [register: 1]
      Module.register_attribute(__MODULE__, :handlers, accumulate: true)
      @before_compile unquote(__MODULE__)
      def start_link, do: Exon.EventBus.start_link(__MODULE__, __handlers__())
      def publish(events, context), do: Exon.EventBus.publish(__MODULE__, events, context)
    end
  end

  defmacro register(handler) do
    quote do
      @handlers unquote(handler)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __handlers__() do
        @handlers
      end
    end
  end

  def start_link(name, handlers) do
    import Supervisor.Spec
    handlers
    |> Enum.map(fn(handler) -> worker(Exon.EventHandler.Server, [handler]) end)
    |> Supervisor.start_link([strategy: :one_for_one, name: name])
  end

  def publish(pid, events, context) do
    Supervisor.which_children(pid)
    |> Enum.each(fn({_, pid, _, _}) ->
      Enum.each(List.wrap(events), fn({event, payload}) ->
        Exon.EventHandler.Server.publish(pid, event, payload, context)
      end)
    end)
  end

  def init(handlers) do
    {:ok, %{handlers: handlers}}
  end
end
