defmodule TodoApp.EventHandler do
  use Exon.EventHandler
  require Logger

  def todo_list_created(_payload) do
    Logger.info("start background job...")
  end

  def todo_list_archived(%{list_uuid: list_uuid}, context) do
    Logger.info("send email about list #{list_uuid} in context #{inspect(context)}")
  end
end
