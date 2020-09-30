defmodule DevopsSkillsMatrixTest do
  use ExUnit.Case

  describe "process" do
    test "should use current dir when no path is given" do
      assert DevopsSkillsMatrix.process() == :ok
    end
  end
  
  describe "parse" do
    test "should return empty json when no files to parse" do
      assert DevopsSkillsMatrix.parse([], []) == []
    end

    test "should parse files recursively" do
      result = DevopsSkillsMatrix.parse(["./test/data/file.xlsx"], [])
      assert result |> Enum.count == 1
    end

    test "should include map with proper key names" do
      result = DevopsSkillsMatrix.parse(["./test/data/file.xlsx"], []) |> List.first
      assert result |> Map.keys == [:name, :skills]
    end

    test "should include map with proper count of skill values" do
      result = DevopsSkillsMatrix.parse(["./test/data/file.xlsx"], []) |> List.first
      assert result |> Map.get(:skills) |> Enum.count == 4
    end
  end

  describe "transform into tools and experience level" do
    test "should split tool from expertise" do
      assert DevopsSkillsMatrix.split_tech_and_expertise(["a(b,c),2", "d,3", "e,4,5"]) == [%{"a(b,c)" => 2}, %{"d" => 3}, %{"e,4" => 5}]
    end
  end

  describe "split skill areas" do
    test "should handle single area" do
      assert DevopsSkillsMatrix.split_areas(["area1,tech1,1","area1,tech2,1"]) == [
        %{area: "area1", skills: ["tech1,1", "tech2,1"]}
      ]
    end
    test "should handle multiple areas" do
      assert DevopsSkillsMatrix.split_areas(["area1,tech1,1","area1,tech2,1","area2,tech3,4"]) == [
        %{area: "area1", skills: ["tech1,1", "tech2,1"]},
        %{area: "area2", skills: ["tech3,4"]}
      ]
    end
  end
end
