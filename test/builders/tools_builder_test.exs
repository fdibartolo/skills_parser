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
end
