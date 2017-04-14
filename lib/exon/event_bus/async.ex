defmodule Exon.EventBus.Async do
  def __using__(_opts) do
    quote do
      @behaviour Exon.EventBus
      import unquote(__MODULE__), only: [register: 1]
      Module.register_attribute(__MODULE__, :handlers, accumulate: true)
      @before_compile unquote(__MODULE__)
      def start_link, do: unquote(__MODULE__).start_link(__MODULE__, __handlers__())
      def publish(events, context), do: unquote(__MODULE__).publish(__MODULE__, events, context)
      def child_spec, do: Supervisor.Spec.supervisor(__MODULE__, [])
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
    |> Enum.map(fn(handler) -> worker(Exon.EventBus.Server, [handler], id: handler) end)
    |> Supervisor.start_link([strategy: :one_for_one, name: name])
  end

  def publish(pid, events, context) do
    Supervisor.which_children(pid)
    |> Enum.each(fn({_, pid, _, _}) ->
      Enum.each(List.wrap(events), fn({event, payload}) ->
        Exon.EventBus.Server.publish(pid, event, payload, context)
      end)
    end)
  end

  def init(handlers) do
    {:ok, %{handlers: handlers}}
  end
end
