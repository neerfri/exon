defmodule TodoApp.EventHandler do
  use Exon.EventHandler
  require Logger

  def handle_event(:todo_list_created, _payload, _context) do
    Logger.info("start background job...")
  end

  def handle_event(:todo_list_archived, payload, _context) do
    Logger.info("send email... #{inspect(payload)}")
  end
end
