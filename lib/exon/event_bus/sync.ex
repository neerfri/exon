defmodule Exon.EventBus.Sync do
  def __using__(_opts) do
    quote do
      @behaviour Exon.EventBus
      import unquote(__MODULE__), only: [register: 1]
      Module.register_attribute(__MODULE__, :handlers, accumulate: true)
      @before_compile unquote(__MODULE__)
      def start_link, do: unquote(__MODULE__).start_link(__MODULE__, __handlers__())
      def publish(events, context), do: unquote(__MODULE__).publish(__MODULE__, events, context)
      def child_spec, do: Supervisor.Spec.worker(__MODULE__, [])
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
    Agent.start_link(fn -> handlers end, name: name)
  end

  def publish(agent, events, context) do
    handlers = Agent.get(agent, &(&1))
    Enum.each(handlers, fn(handler) ->
      Enum.each(List.wrap(events), fn({event, payload}) ->
        Exon.EventBus.handle_event(handler, event, payload, context)
      end)
    end)
  end
end
