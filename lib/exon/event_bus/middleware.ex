defmodule Exon.EventBus.Middleware do
  use Exon.Middleware
  alias Exon.Command

  @private_key :event_bus

  def put_event(%Command{private: private} = command, [event]) do
    private = Map.put(private, @private_key, [event | Map.get(private, @private_key, [])])
    %{command | private: private}
  end

  def get_events(%Command{private: private}) do
    get_in(private, [Access.key(@private_key, [])])
  end

  def init(opts) do
    %{event_bus: Keyword.fetch!(opts, :event_bus)}
  end

  def after_dispatch(%Command{context: context, result: result} = command, %{event_bus: event_bus}) do
    events = get_events(command)
    if events && !error_result?(result) do
      event_bus.publish(events, context)
    end
    command
  end

  defp error_result?(result) do
    is_tuple(result) && elem(result, 0) == :error
  end
end
