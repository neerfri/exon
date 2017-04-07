defmodule Exon.TestApp.CommandDispatcher do
  use Exon.CommandDispatcher
  alias Exon.TestApp.Domain.Commands.{
    CreateTodoList,
    CreateTodoItem,
  }

  dispatch [
    CreateTodoList,
    CreateTodoItem,
  ], to: :somewhere
end
