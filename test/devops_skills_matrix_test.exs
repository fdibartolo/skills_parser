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

    test "should parse files recursively" do
      files = ["f1", "f2", "f3"]
      result = DevopsSkillsMatrix.parse(files, Map.new)
      assert result |> Map.keys == files
    end
  end
end
