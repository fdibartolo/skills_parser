defmodule ToolsBuilderTest do
  use ExUnit.Case

  describe "build" do
    test "should handle empty list" do
      assert ToolsBuilder.build([]) |> is_map
    end

    test "should include all expected labels" do
      assert ToolsBuilder.build([]) |> Map.keys == [:dataset, :labels, :tools]
    end
  end

  describe "list of tools" do
    test "should combine category and list into single list" do
      list = %{"foo" => ~w(t1 t2), "bar" => ~w(t1)}
      assert ToolsBuilder.build_tools(list) == ["bar - t1", "foo - t1", "foo - t2"]
    end
  end
end
