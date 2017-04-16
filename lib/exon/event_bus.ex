defmodule Exon.EventBus do
  defmacro __using__(_opts) do
    quote do
      @name __MODULE__
      @agent __MODULE__.Agent

      def start_link(handlers),
        do: Agent.start_link(fn -> MapSet.new(handlers) end, name: @agent)
      def handlers(),
        do: Agent.get(@agent, &(&1))
      def add_handler(handler),
        do: Agent.update(@agent, &MapSet.put(&1, handler))
      def publish(events, context),
        do: unquote(__MODULE__).publish(handlers(), events, context)
    end
  end

  def publish(handlers, events, context) do
    handlers
    |> Enum.map(&call_handler_task(&1, events, context))
    |> Enum.map(&Task.async/1)
    |> Enum.map(&Task.await/1)
    :ok
  end

  defp call_handler_task(handler, events, context) do
    fn() ->
      Enum.each(events, fn({name, payload}) ->
        handler.__handle_event__(name, payload, context)
      end)
    end
  end
end
