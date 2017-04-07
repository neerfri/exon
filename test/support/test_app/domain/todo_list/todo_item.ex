defmodule Exon.TestApp.Domain.TodoList.TodoItem do
  use Ecto.Schema

  schema "todo_items" do
    field :title, :string
    belongs_to :list, Exon.TestApp.Domain.TodoList
  end
end
