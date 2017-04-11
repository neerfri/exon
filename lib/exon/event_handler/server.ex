defmodule Exon.EventHandler.Server do
  use GenServer

  def start_link(handler) do
    GenServer.start_link(__MODULE__, handler)
  end

  def init(handler) do
    {:ok, %{handler: handler}}
  end

  def publish(pid, event, payload, context) do
    GenServer.call(pid, {:publish, event, payload, context})
  end

  def handle_call({:publish, event, payload, context}, _from, %{handler: handler} = state) do
    cond do
      function_exported?(handler, event, 2) -> apply(handler, event, [payload, context])
      function_exported?(handler, event, 1) -> apply(handler, event, [payload])
      function_exported?(handler, :handle_event, 3) -> apply(handler, :handle_event, [event, payload, context])
      true -> :ok
    end
    {:reply, :ok, state}
  end
end
