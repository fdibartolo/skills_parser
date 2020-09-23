defmodule DevopsSkillsMatrixTest do
  use ExUnit.Case

  test "should use current dir when no path is given" do
    assert DevopsSkillsMatrix.process() |> Enum.empty?
  end
end
