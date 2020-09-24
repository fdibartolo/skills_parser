defmodule UtilsTest do
  use ExUnit.Case

  describe "get files" do
    test "should return only excel files" do
      files = Utils.get_files("./test/data")
      assert files |> Enum.count == 1
      assert files |> Enum.any?(fn f -> String.contains?(f, "file.xlsx") end)
      refute files |> Enum.any?(fn f -> String.contains?(f, "another.docx") end)
    end

    test "should include absolute path" do
      assert Utils.get_files("./test/data") |> Enum.member?("./test/data/file.xlsx")
    end
  end

  describe "create output file" do
    test "should create file" do
      Utils.create_output_file("")
      assert File.exists? "./output.json"
    end

    test "should save file content" do
      content = "foo bar"
      Utils.create_output_file(content)
      assert File.read("./output.json") == {:ok, content}
    end
  end
end
