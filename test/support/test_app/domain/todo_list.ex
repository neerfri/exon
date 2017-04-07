defmodule Exon.TestApp.Domain.TodoList do
  use Ecto.Schema
  alias __MODULE__, as: TodoList

  schema "todo_lists" do
    field :title, :string
    has_many :items, TodoList.TodoItem
  end
end
