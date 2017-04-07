defmodule Exon.CommandGateway do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Exon.CommandGateway
      @repo opts[:repo]
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
            @repo
            )
        end
      end)
    end
  end

  def execute(aggregate_module, command_name, payload, spec, repo) do
    aggregate = get_aggregate(aggregate_module, payload, spec, repo)
    case apply(aggregate_module, command_name, [aggregate, payload]) do
      :ok -> :ok
      {:ok, changeset} ->
        repo.insert_or_update(changeset)
      {:ok, changeset, events} ->
        repo.insert_or_update(changeset)
        IO.puts "publish events: #{inspect(events)}"
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
