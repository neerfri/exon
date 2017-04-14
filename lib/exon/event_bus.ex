defmodule Exon.EventBus do
  @moduledoc """
  An event bus behaviour and convenience macro.

  Use `Exon.EventBus` to define an event bus for your application.
  You can either use: `use Exon.EventBus, :sync` or `use Exon.EventBus, :async`.
  """

  @type event :: {atom, map}
  @type events :: [event]
  @type context :: map

  @callback publish(events, context) :: :ok
  @callback child_spec() :: Supervisor.Spec.spec

  defmacro __using__([]) do
    apply(Exon.EventBus.Sync, :__using__, [[]])
  end

  defmacro __using__(:sync) do
    apply(Exon.EventBus.Sync, :__using__, [[]])
  end

  defmacro __using__(:async) do
    apply(Exon.EventBus.Async, :__using__, [[]])
  end

  @doc "A shared utility function to apply the event handling method on a handler"
  def handle_event(handler, event, payload, context) do
    Code.ensure_loaded(handler)
    cond do
      function_exported?(handler, event, 2) -> apply(handler, event, [payload, context])
      function_exported?(handler, event, 1) -> apply(handler, event, [payload])
      function_exported?(handler, :handle_event, 3) -> apply(handler, :handle_event, [event, payload, context])
      true -> :ok
    end
  end
end
