defmodule Exon.Command do
  defstruct [
    :module,
    :func,
    :payload,
    :context,
    :spec,
    :result,
    :aggregate,
    :private,
  ]

  def new(module, func, payload, context, spec) do
    %__MODULE__{
      module: module,
      func: func,
      payload: payload,
      context: context,
      spec: spec,
      private: %{}
    }
  end

  def put_result(%__MODULE__{} = command, result) do
    %{command | result: result}
  end
end
