defmodule Exon.Ecto.AggregateRoot do
  @doc"""
  A callback to define the query used to fetch the `Ecto` aggregate

  The value of the `id` argument is taken from the command's payload using the
  key provided as `:aggregate_id` in the command spec.
  """
  @callback get(id :: term) :: Ecto.Queryable.t
end
