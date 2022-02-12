defmodule Cqrs.EntityTest do
  use ExUnit.Case, async: true
  alias Cqrs.EntityTestMessages.Protocol.{Entity1, Entity2}

  test "entity has id field by default" do
    fields = Entity1.__schema__(:fields)
    assert Enum.member?(fields, :id)
  end

  test "entities with no fields defined have new/1 and new/2 functions" do
    assert [1, 2] == Entity1.__info__(:functions) |> Keyword.get_values(:new)
  end

  test "entities can't be dispatched" do
    assert Entity1.__info__(:functions)[:dispatch] == nil
  end

  test "entities required their primary key to assigned" do
    assert {:error, %{id: ["can't be blank"]}} = Entity1.new(%{})
    assert {:error, %{id: ["is invalid"]}} = Entity1.new(%{id: "2342"})
    id = UUID.uuid4()
    assert {:ok, %Entity1{id: ^id}, _discared_data} = Entity1.new(id: id)
  end

  describe "custom primary key" do
    test "unable to set to false" do
      code = """
      defmodule E do
        use Cqrs.Entity, identity: false
      end
      """

      assert_raise Cqrs.Entity.Error, "Entities require a primary key", fn ->
        Code.compile_string(code)
      end
    end

    test "unable to set to nil" do
      code = """
      defmodule E do
        use Cqrs.Entity, identity: nil
      end
      """

      assert_raise Cqrs.Entity.Error, "Entities require a primary key", fn ->
        Code.compile_string(code)
      end
    end

    test "must be tuple" do
      code = """
      defmodule E do
        use Cqrs.Entity, identity: :abc
      end
      """

      assert_raise Cqrs.Entity.Error,
                   "identity must be either {name, type} or {name, type, options}",
                   fn ->
                     Code.compile_string(code)
                   end
    end

    test "can customize identity field" do
      fields = Entity2.__schema__(:fields)
      refute Enum.member?(fields, :id)
      assert Enum.member?(fields, :ident)
      assert :binary_id = Entity2.__schema__(:type, :ident)
    end
  end
end
