defmodule Exon.CommandDispatcher do
  defmacro __using__(_opts) do
    quote location: :keep do
      require Logger
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @default_dispatch_timeout 5_000
      Module.register_attribute(__MODULE__, :commands, accumulate: true)
      Module.register_attribute(__MODULE__, :middlewares, accumulate: true)
    end
  end

  defmacro dispatch(commands, opts) when is_list(commands) do
    quote bind_quoted: [commands: commands, opts: opts] do
      for command <- commands do
        dispatch(command, opts)
      end
    end
  end

  defmacro dispatch(command, opts) do
    quote bind_quoted: [command: command, opts: opts] do
      Module.put_attribute(__MODULE__, :commands, {command, opts})
    end
  end

  def __dispatch__(command, opts, context) do
    # aggregate_module = command.__aggregate__
    # aggregate_id = command.__aggregate_id__
    # IO.inspect([command, opts, context])
    # with  aggregate <- aggregate_repo.get(aggregate_module, aggregate_id),
    #       events <- execute(aggregate, command),
    #       :ok <- publish_events(events),

  end

  defmacro __before_compile__(env) do
    Module.get_attribute(env.module, :commands)
    |> Enum.map(fn({command_module, opts}) ->
      quote do
        def dispatch(%unquote(command_module){} = command, context) do
          Exon.CommandDispatcher.__dispatch__(command, unquote(opts), context)
        end
      end
    end)
    |> Enum.concat([
      quote do
        def dispatch(command, context) do
          Logger.error("unknown command dispatched: #{inspect(command)}")
          {:error, :unknown_command}
        end
      end
    ])
  end
end
