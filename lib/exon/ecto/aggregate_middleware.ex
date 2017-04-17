defmodule Exon.Ecto.AggregateMiddleware do
  use Exon.Middleware
  @private_key :ecto_aggregate

  def put_changeset(%Command{private: private} = command, changeset) do
    private = put_in(private, [Access.key(@private_key, %{}), :changeset], changeset)
    %{command | private: private}
  end

  def get_changeset(%Command{private: private}) do
    get_in(private, [Access.key(@private_key, %{}), :changeset])
  end

  def init(opts) do
    %{repo: Keyword.fetch!(opts, :repo)}
  end

  def before_dispatch(%Command{module: aggregate_module, payload: payload, spec: spec} = command, %{repo: repo}) do
    if ecto_aggregate?(aggregate_module) do
      aggregate = get_aggregate(aggregate_module, payload, spec, repo)
      %{command | aggregate: aggregate}
    else
      command
    end
  end

  def after_dispatch(%Command{module: module} = command, %{repo: repo}) do
    if ecto_aggregate?(module) do
      case get_changeset(command) do
        %Ecto.Changeset{} = changeset ->
          save_and_alter_result(command, changeset, repo)
        _ -> command
      end
    else
      command
    end
  end

  defp save_and_alter_result(%{result: result} = command, changeset, repo) do
    case repo.insert_or_update(changeset) do
      {:ok, aggregate} ->
        if result == nil do
          %{command | result: {:ok, aggregate}}
        else
          command
        end
      other ->
        %{command | result: other}
    end
  end

  defp ecto_aggregate?(module) do
    Code.ensure_loaded?(module) && function_exported?(module, :__schema__, 1)
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
