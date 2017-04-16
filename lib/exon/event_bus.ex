defmodule Exon.EventBus do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      @name __MODULE__

      def start_link(), do: GenServer.start_link(unquote(__MODULE__), :ok, name: @name)
      def add_handler(handler), do: GenServer.call(@name, {:add_handler, handler})
      def publish(events, context), do: GenServer.call(@name, {:publish, events, context})
    end
  end

  def init(_) do
    {:ok, %{handlers: MapSet.new}}
  end

  def handle_call({:publish, events, context}, _from, %{handlers: handlers} = state) do
    handlers
    |> Enum.map(&call_handler_task(&1, events, context))
    |> Enum.map(&Task.async/1)
    |> Enum.map(&Task.await/1)
    {:reply, :ok, state}
  end

  def handle_call({:add_handler, handler}, _from, %{handlers: handlers} = state) do
    {:reply, :ok, %{state | handlers: MapSet.put(handlers, handler)}}
  end

  def handle_call({:handlers}, _from, %{handlers: handlers} = state) do
    {:reply, Enum.into(handlers, []), state}
  end

  defp call_handler_task(handler, events, context) do
    fn() ->
      Enum.each(events, fn({name, payload}) ->
        handler.__handle_event__(name, payload, context)
      end)
    end
  end
end
