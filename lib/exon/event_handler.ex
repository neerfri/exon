defmodule Exon.EventHandler do
  defmacro __using__(_) do
    quote do
      @handler __MODULE__
      @before_compile unquote(__MODULE__)
      def __handle_event__(event, payload, context),
        do: @handler.handle_event(event, payload, context)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_event(_name, _payload, _context), do: :ok
    end
  end
end
