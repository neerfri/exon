defmodule Exon.EventHandler do
  defmacro __using__(_) do
    quote do
      use GenServer
      @handler __MODULE__
      @before_compile unquote(__MODULE__)
      def start_link(opts),
        do: GenServer.start_link(unquote(__MODULE__), {@handler, opts}, name: @handler)
      def __handle_event__(event, payload, context),
        do: GenServer.call(@handler, {:handle_event, event, payload, context})
    end
  end

  def init({handler, opts}) do
    event_bus = Keyword.get(opts, :event_bus)
    event_bus.add_handler(handler)
    {:ok, %{handler: handler, event_bus: event_bus}}
  end

  def handle_call({:handle_event, event, payload, context}, _from, %{handler: handler} = state) do
    handler.handle_event(event, payload, context)
    {:reply, :ok, state}
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_event(_name, _payload, _context), do: :ok
    end
  end
end
