defmodule UtilsTest do
  use ExUnit.Case

  describe "get files" do
    test "should return only excel files" do
      assert Utils.get_files("./test/data") |> Enum.member?("file.xlsx")
      refute Utils.get_files("./test/data") |> Enum.member?("another.docx")
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
