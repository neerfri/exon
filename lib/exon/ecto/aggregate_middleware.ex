defmodule Exon.Ecto.AggregateMiddleware do
  use Exon.Middleware
  @private_key :ecto_aggregate

  defmodule MissingAggregateIdError do
    defexception message: """
      Command is missing :aggregate_id
      There are two way to specify :aggregate_id
      1. Using the @command attribute: `@command aggregate_id: :my_id`
      2. Using the options for `Exon.AggregateRoot`: `use Exon.AggregateRoot, default_aggregate_id: :my_id`
      """
  end

  def put_changeset(%Command{private: private} = command, changeset) do
    private = put_in(private, [Access.key(@private_key, %{}), :changeset], changeset)
    %{command | private: private}
  end

  def get_changeset(%Command{private: private}) do
    get_in(private, [Access.key(@private_key, %{}), :changeset])
  end

  def get_action(%Command{private: private}) do
    get_in(private, [Access.key(@private_key, %{}), :action])
  end

  def put_delete(%Command{private: private} = command, _aggregate) do
    private = put_in(private, [Access.key(@private_key, %{}), :action], :delete)
    %{command | private: private}
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
          perform_insert_or_update(command, changeset, repo)
        _ ->
          case get_action(command) do
            :delete ->
              perform_delete(command, repo)
            _ -> command
          end
      end
    else
      command
    end
  end

  defp perform_insert_or_update(command, changeset, repo) do
    command
    |> handle_repo_result(repo.insert_or_update(changeset))
  end

  defp perform_delete(command, repo) do
    command
    |> handle_repo_result(repo.delete(command.aggregate))
  end

  defp handle_repo_result(%{result: result} = command, repo_response) do
    case repo_response do
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
      unless spec[:aggregate_id], do: raise(MissingAggregateIdError)
      id = payload[spec[:aggregate_id]]
      query = aggregate_module.get(id)
      if spec[:allow_nil], do: repo.one(query), else: repo.one!(query)
    end
  end
end
