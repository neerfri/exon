defmodule TodoApp.EventHandler do
  use Exon.EventHandler
  require Logger

  def handle_event(:todo_list_created, payload) do
    Logger.info("start background job...")
  end

  def handle_event(:todo_list_archived, payload) do
    Logger.info("send email... #{inspect(payload)}")
  end
end
