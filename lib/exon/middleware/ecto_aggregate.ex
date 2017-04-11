defmodule Exon.Middleware.EctoAggregate do
  use Exon.Middleware

  def init(opts) do
    %{repo: Keyword.fetch!(opts, :repo)}
  end

  def before_dispatch(%Env{module: aggregate_module, payload: payload, spec: spec} = env, %{repo: repo}) do
    if ecto_aggregate?(aggregate_module) do
      aggregate = get_aggregate(aggregate_module, payload, spec, repo)
      %{env | args: [aggregate, payload]}
    else
      env
    end
  end

  def after_dispatch(%Env{module: module, result: result} = env, %{repo: repo}) do
    if ecto_aggregate?(module) do
      case result do
        :ok -> env
        {:ok, %Ecto.Changeset{} = changeset} ->
          %{env | result: save_and_alter_result(result, changeset, repo)}
        {:ok, changeset, _} ->
          %{env | result: save_and_alter_result(result, changeset, repo)}
      end
    end
  end

  defp save_and_alter_result(result, changeset, repo) do
    case repo.insert_or_update(changeset) do
      {:ok, aggregate} -> put_elem(result, 1, aggregate)
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp ecto_aggregate?(module) do
    function_exported?(module, :__schema__, 1)
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
