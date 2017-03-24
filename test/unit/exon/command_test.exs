defmodule Exon.CommandTest do
  use ExUnit.Case, async: true

  defmodule TestCommand do
    use Exon.Command

    fields do
      field :string_field, :string
      field :integer_field, :integer
    end
  end

  test "create a new command with string params" do
    command = TestCommand.new(%{"string_field" => "123", "integer_field" => 456})
    assert %TestCommand{string_field: "123", integer_field: 456} = command
  end
end
