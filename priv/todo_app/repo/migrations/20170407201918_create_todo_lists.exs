defmodule Exon.TodoApp.Repo.Migrations.CreateTodoLists do
  use Ecto.Migration

  def change do
    create table(:todo_lists) do
      add :uuid, :string
      add :name, :string
      add :archived, :boolean
    end
  end
end
