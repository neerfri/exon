defmodule Exon.Command do
  import Ecto.Changeset, only: [cast: 3, apply_changes: 1]

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Exon.Command, only: [fields: 1]
      import Ecto.Changeset
      @primary_key false


      def new(params), do: Exon.Command.new(__MODULE__, params)
    end
  end

  defmacro fields(opts), do: quote(do: Ecto.Schema.embedded_schema(unquote(opts)))

  def new(module, params) do
    module
    |> struct()
    |> cast(params, module.__schema__(:fields))
    |> apply_changes()
  end
end
