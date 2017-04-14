defmodule Exon.EventBus.Server do
  @moduledoc false
  use GenServer

  def start_link(handler) do
    GenServer.start_link(__MODULE__, handler)
  end

  def init(handler) do
    {:ok, %{handler: handler}}
  end

  def publish(pid, event, payload, context) do
    GenServer.cast(pid, {:publish, event, payload, context})
  end

  def handle_cast({:publish, event, payload, context}, %{handler: handler} = state) do
    Exon.EventBus.handle_event(handler, event, payload, context)
    {:noreply, state}
  end
end
