defmodule Exon.Middleware.ExonEventBus do
  use Exon.Middleware

  def init(opts) do
    %{event_bus: Keyword.fetch!(opts, :event_bus)}
  end

  def after_dispatch(%Env{result: result} = env, %{event_bus: event_bus}) do
    case result do
      {:ok, _, events} ->
        if Keyword.keyword?(events) do
          event_bus.publish(events)
          %{env | result: Tuple.delete_at(result, 2)}
        else
          env
        end
      other -> env
    end
  end
end
