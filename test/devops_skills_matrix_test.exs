defmodule DevopsSkillsMatrixTest do
  use ExUnit.Case

  describe "process" do
    test "should use current dir when no path is given" do
      assert DevopsSkillsMatrix.process() |> Enum.empty?
    end
  end
  
  describe "parse" do
    test "should return empty json when no files to parse" do
      assert DevopsSkillsMatrix.parse([], Map.new) == %{}
    end

    test "should parse files recursively with cols data" do
      result = DevopsSkillsMatrix.parse(["./test/data/test.xlsx"], Map.new)
      assert result |> Map.keys |> Enum.count == 1
      assert result |> Map.values |> List.first |> Enum.count == 4
    end
  end
end
