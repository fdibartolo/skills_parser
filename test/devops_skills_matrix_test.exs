defmodule DevopsSkillsMatrixTest do
  use ExUnit.Case

  describe "process" do
    test "should use current dir when no path is given" do
      assert DevopsSkillsMatrix.process() |> Enum.empty?
    end
  end
  
  describe "parse" do
    test "should return empty json when no files to parse" do
      assert DevopsSkillsMatrix.parse([]) == {}
    end
  end
end
