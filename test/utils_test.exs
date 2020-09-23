defmodule UtilsTest do
  use ExUnit.Case

  test "should return only excel files" do
    assert Utils.get_files("./test/data") |> Enum.member?("file.xlsx")
    refute Utils.get_files("./test/data") |> Enum.member?("another.docx")
  end
end
