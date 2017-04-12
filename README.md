# Exon

A collection of useful concepts for building data backed applications in Elixir

`Exon` draw inspiration from DDD's approach to domain modeling.
It encourages the use of aggregates, commands and events to describe the application's
domain.



## Usage

Add `Exon` to your `mix.exs` file:

```
defp deps do
  [
    {:exon, "~> 0.1.3"},
  ]
end
```

## Concepts

### Command

A Command is a module function responsible for a specific write operation
of the application.

### Command Gateway

A CommandGateway is a module responsible for dispatching commands to their respective
aggregate root. A CommandGateway should `use Exon.CommandGateway`.

### Aggregate Root

A module that represents an entity or a group of entities in the domain.
Every command is dispatched to a single aggregate root. This makes the aggregate
root a transaction boundary for every command in the system.
An Aggregate Root should `use Exon.AggregateRoot` which provides the command registration
mechanism using the `@command` method annotation.

### Event Bus

A module responsible for publishing domain events to it's registered event handlers.
An event bus should `use Exon.EventBus` which provides a supervisor based publisher
and the `register` macro to register event handlers.

### Event handler

A module responsible of domain logic that should be executed when a specific domain
event is raised.
An event handler can handle zero or more domain events.
An event will can be handled in one of three ways (searched in that order):

1. `def my_domain_event(payload, context)`
1. `def my_domain_event(payload)`
1. `def handle_event(event, payload, context)`

### Middleware

A module that is registered using `middleware/1` in the command gateway.
It's `before_dispatch/2` and `after_dispatch/2` functions will be called before
and after dispatching the command to the aggregate root.

The `before_dispatch/2` can be used to change most aspects of the command execution.
For example `Exon.Middleware.EctoAggregate` will fetch the correct entity from the
DB and add it as the first argument for the command method.

The `after_dispatch/2` can be used to handle changes that should happen after a
successful or failed command execution. For example `Exon.Middleware.EctoAggregate`
will save a changeset in case one is returned from the command.

## Example

See the code for `TodoApp` under `test/support/todo_app`.
