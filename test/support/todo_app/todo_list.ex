defmodule TodoApp.TodoList do
  use Exon.AggregateRoot, default_aggregate_id: :list_uuid
  use Ecto.Schema

  alias __MODULE__, as: TodoList
  alias Exon.Command

  import Ecto.Changeset
  import Exon.Ecto.AggregateMiddleware, only: [put_changeset: 2, put_delete: 1]
  import Exon.EventBus.Middleware, only: [put_event: 2]
  import Exon.Command, only: [put_result: 2]


  schema "todo_lists" do
    field :uuid
    field :name
    field :archived, :boolean
  end

  @command new: true
  def create_todo_list(%Command{aggregate: list, payload: %{list_uuid: list_uuid, name: name}} = command) do
    command
    |> put_changeset(changeset(list, %{uuid: list_uuid, name: name}))
    |> put_event(todo_list_created: %{list_uuid: list_uuid, name: name})
  end

  @command []
  def archive_todo_list(%Command{aggregate: %TodoList{archived: true} = list} = command) do
    put_result(command, {:ok, list})
  end

  def archive_todo_list(%Command{aggregate: %TodoList{} = list} = command) do
    command
    |> put_changeset(change(list, %{archived: true}))
    |> put_event(todo_list_archived: %{list_uuid: list.uuid})
  end

  @command []
  def delete_todo_list(%Command{aggregate: list} = command) do
    command
    |> put_delete()
  end

  @command []
  def restore_todo_list(%Command{aggregate: %TodoList{} = list} = command) do
    command
    |> put_changeset(change(list, %{archived: false}))
  end

  def changeset(model, changes) do
    change(model, changes)
    |> validate_required([:uuid, :name])
  end

  def get(uuid) do
    import Ecto.Query, only: [from: 2]
    from(l in TodoList, where: l.uuid == ^uuid)
  end
end
