defmodule UtilsTest do
  use ExUnit.Case

  test "should use current dir when no path is given" do
    assert Utils.get_files() == []
  end

end
