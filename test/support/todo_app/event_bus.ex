defmodule TodoApp.EventBus do
  use Exon.EventBus

  register TodoApp.EventHandler
end
