defmodule Support.Command.EventDerivationTest.CommandWithEventDerivations do
  use Cqrs.Command
  use Cqrs.Command.EventDerivation

  field :name, :string, required: true
  field :dog, :string, default: "maize"

  derive_event DefaultEvent

  derive_event EventWithExtras do
    field :date, :date
  end

  derive_event EventWithDrops, drop: [:dog]

  derive_event EventWithExtrasAndDrops, drop: [:dog] do
    field :date, :date
  end

  @event_ns Cqrs.CommandTest.Events

  derive_event NamespacedEventWithExtrasAndDrops, drop: [:dog], ns: @event_ns do
    field :date, :date
  end
end
