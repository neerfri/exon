defmodule Exon.AggregateRoot do
  defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      alias Exon.Command
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :commands, accumulate: true)
      @on_definition {unquote(__MODULE__), :on_definition}
      @before_compile unquote(__MODULE__)
      @default_aggregate_id opts[:default_aggregate_id]
    end
  end

  def on_definition(env, :def, name, _args, _guards, _body) do
    case Module.get_attribute(env.module, :command) do
      nil -> :ok
      spec ->
        spec =
          spec
          |> Keyword.put_new(:aggregate_id, Module.get_attribute(env.module, :default_aggregate_id))

        if spec_invalid?(spec), do: raise(ArgumentError, invalid_spec_error_message(env.module, name))
        if spec_exists?(name, Module.get_attribute(env.module, :commands)) do
          raise(ArgumentError, duplicate_command_spec_error_message(env.module, name))
        end
        Module.put_attribute(env.module, :commands, {name, spec})
        Module.put_attribute(env.module, :command, nil)
    end
  end
  def on_definition(_env, _kind, _name, _args, _guards, _body), do: :ok

  defp spec_invalid?(spec), do: !spec[:new] && !spec[:aggregate_id]
  defp spec_exists?(name, commands), do: Keyword.has_key?(commands, name)

  defp invalid_spec_error_message(module, name) do
    "@command options for #{inspect(module)}.#{name} must have either :new or :aggregate_id defined"
  end

  defp duplicate_command_spec_error_message(module, name) do
    "@command was set twice for #{inspect(module)}.#{name}. You only need to annotate the first definition"
  end

  defmacro __before_compile__(_env) do
    quote do
      def __commands__() do
        @commands
      end
    end
  end
end
