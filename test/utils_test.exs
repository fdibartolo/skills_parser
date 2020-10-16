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

  describe "get directories" do
    test "should return not empty directories" do
      assert Utils.get_dirs("./test/") |> Enum.member?("./test/data")
      assert Utils.get_dirs("./config/") |> Enum.empty?
    end
  end

  describe "create output file" do
    test "should create file" do
      Utils.create_file("", "output.json")
      assert File.exists? "./output.json"
    end

    test "should save file content" do
      content = "foo bar"
      Utils.create_file(content, "output.json")
      assert File.read("./output.json") == {:ok, content}
    end
  end

  describe "purge skills list" do
    test "should remove blanks" do
      assert Utils.purge(["a,1", "", " ", "b,2"]) == ["a,1", "b,2"]
    end
    test "should remove dashes" do
      assert Utils.purge(["a,1", "-", " ", "b,2"]) == ["a,1", "b,2"]
    end
    test "should accept only 'tech,experience'" do
      assert Utils.purge(["a,1", "c,", ",2", "b", "x,y,3"]) == ["a,1", "x,y,3"]
    end
  end

  describe "transpose and reduce list of arrays" do
    test "should transpose!" do
      assert Utils.transpose([[1,2,3],[4,5,6]]) == [[1,4],[2,5],[3,6]]
    end
    test "should reduce!" do
      assert Utils.reduce([[1,4],[2,5],[3,6]]) == [5,7,9]
    end
  end

  describe "shorten list" do
    test "should keep only the first word of each element" do
      assert Utils.shorten(["a b", "aab ab", "c", "dd e f"]) == ["a", "aab", "c", "dd"]
    end
  end

end
