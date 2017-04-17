defmodule Exon.Middleware do
  defmacro __using__(_opts) do
    quote do
      alias Exon.Command
      @behaviour Exon.Middleware
    end
  end

  @type state :: term

  @callback init(Keyword.t) :: state
  @callback before_dispatch(Exon.Command.Env.t, state) :: Exon.Command.Env.t
  @callback after_dispatch(Exon.Command.Env.t, state) :: Exon.Command.Env.t

  @optional_callbacks before_dispatch: 2, after_dispatch: 2
end
