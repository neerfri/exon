defmodule Exon.TestApp.AggregateRepo do
  @ecto_aggregates [
    Exon.TestApp.Domain.TodoList
  ]

  def get(module, id) when module in @ecto_aggregates do
    Exon.TestApp.EctoRepo.get(module, id)
  end
end
