defmodule Exon.CommandGateway do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Exon.CommandGateway
      @repo opts[:repo]
      @event_bus opts[:event_bus]
    end
  end

  defmacro commands_from(aggregate_module) do
    quote bind_quoted: [aggregate_module: aggregate_module], location: :keep do
      Enum.each(aggregate_module.__commands__(), fn({name, spec}) ->
        def unquote(name)(payload, context \\ [])
        def unquote(name)(payload, context) do
          Exon.CommandGateway.execute(
            unquote(aggregate_module),
            unquote(name),
            payload,
            unquote(spec),
            @repo,
            @event_bus
            )
        end
      end)
    end
  end

  def execute(aggregate_module, command_name, payload, spec, repo, event_bus) do
    aggregate = get_aggregate(aggregate_module, payload, spec, repo)
    case apply(aggregate_module, command_name, [aggregate, payload]) do
      :ok -> :ok
      {:ok, changeset} ->
        repo.insert_or_update(changeset)
      {:ok, changeset, events} ->
        case repo.insert_or_update(changeset) do
          {:ok, aggregate} ->
            event_bus.publish(events)
            {:ok, aggregate}
          other -> other
        end
    end
  end

  defp get_aggregate(aggregate_module, payload, spec, repo) do
    if spec[:new] do
      struct(aggregate_module)
    else
      aggregate_module.get(payload[spec[:aggregate_id]])
      |> repo.one()
    end
  end
end
