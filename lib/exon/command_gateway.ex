defmodule Exon.CommandGateway do
  alias Exon.Command
  require Logger

  defmacro __using__(_opts) do
    quote do
      import Exon.CommandGateway, only: [commands_from: 1, middleware: 1, middleware: 2]
      Module.register_attribute(__MODULE__, :middlewares, accumulate: true)
    end
  end

  defmacro commands_from(aggregate_module) do
    quote bind_quoted: [aggregate_module: aggregate_module], location: :keep do
      Enum.each(aggregate_module.__commands__(), fn({name, spec}) ->
        def unquote(name)(payload, context \\ [])
        def unquote(name)(payload, context) do
          Exon.CommandGateway.execute(
            Enum.reverse(@middlewares),
            unquote(aggregate_module),
            unquote(name),
            payload,
            context,
            unquote(spec)
            )
        end
      end)
    end
  end

  defmacro middleware(middleware_module, opts \\ []) do
    quote bind_quoted: [middleware_module: middleware_module, opts: opts] do
      @middlewares {middleware_module, middleware_module.init(opts)}
    end
  end

  def execute(middlewares, aggregate_module, command_name, payload, context, spec) do
    ensure_middleware_modules_loaded!(middlewares)
    Exon.Command.new(aggregate_module, command_name, payload, context, spec)
    |> before_dispatch(middlewares)
    |> dispatch()
    |> after_dispatch(middlewares)
    |> Map.get(:result)
  end

  defp ensure_middleware_modules_loaded!(middlewares) do
    Enum.each(middlewares, fn({middleware, _}) ->
      unless Code.ensure_loaded?(middleware) do
        raise ArgumentError, "Middleware #{inspect(middleware)} is not loaded"
      end
    end)
  end

  defp dispatch(%{module: module, func: func} = command) do
    apply_and_ensure_command(module, func, [command])
  end

  defp before_dispatch(command, middlewares) do
    Enum.reduce_while(middlewares, command, fn({middleware, opts}, command) ->
      if function_exported?(middleware, :before_dispatch, 2) do
        Logger.debug("Running #{inspect(middleware)}.before_dispatch for #{command.func}")
        {:cont, apply_and_ensure_command(middleware, :before_dispatch, [command, opts])}
      else
        {:cont, command}
      end
    end)
  end

  defp after_dispatch(command, middlewares) do
    Enum.reduce(middlewares, command, fn({middleware, opts}, command) ->
      if function_exported?(middleware, :after_dispatch, 2) do
        Logger.debug("Running #{inspect(middleware)}.after_dispatch for #{command.func}")
        apply_and_ensure_command(middleware, :after_dispatch, [command, opts])
      else
        command
      end
    end)
  end

  defp apply_and_ensure_command(module, func, args) do
    case apply(module, func, args) do
      %Command{} = command -> command
      other -> raise("Bad return value from #{inspect(module)}.#{func}: #{inspect(other)}")
    end
  end
end
