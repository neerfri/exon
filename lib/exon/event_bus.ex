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
    GenServer.start_link(__MODULE__, handlers, name: name)
  end

  def publish(pid, events, context) do
    GenServer.call(pid, {:publish, List.wrap(events), context})
  end

  def init(handlers) do
    {:ok, %{handlers: handlers}}
  end

  def handle_call({:publish, events, context}, _from, %{handlers: handlers} = state) when is_list(events) do
    Enum.each(events, fn({name, payload}) ->
      Enum.each(handlers, fn(handler) ->
        apply(handler, :handle_event, [name, payload, context])
      end)
    end)
    {:reply, :ok, state}
  end
end
