defmodule Exon.EventHandler do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_event(_name, _payload, _context), do: :ok
    end
  end
end
