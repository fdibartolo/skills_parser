defmodule OverviewBuilderTest do
  use ExUnit.Case

  test "should handle empty list" do
    assert OverviewBuilder.build([], []) == []
  end

  test "should aggregate skills by area in single dataset" do
    content = [%{areas: [%{area: "a1", skills: [%{"s1" => 2}, %{"s2" => 3}]}, %{area: "a2", skills: [%{"s3" => 2}, %{"s4" => 1}]}]}]
    assert OverviewBuilder.build(content,[]) == [%{capability: "DevOps", data: [5,3]}]
  end

  test "should aggregate skills by area in multiple dataset" do
    content = [%{areas: [%{area: "a1", skills: [%{"s1" => 2}, %{"s2" => 3}]}]}, %{areas: [%{area: "a1", skills: [%{"s1" => 1}, %{"s2" => 1}]}]}]
    assert OverviewBuilder.build(content,[]) == [%{capability: "DevOps", data: [7]}]
  end

  test "group single capability single dimension dataset" do
    list = [%{capability: "A", data: [5]}, %{capability: "A", data: [2]}]
    assert OverviewBuilder.group_by_capability(list) == [%{capability: "A", data: [7]}]
  end
  
  test "group single capability multiple dimension dataset" do
    list = [%{capability: "A", data: [5,1]}, %{capability: "A", data: [2,2]}]
    assert OverviewBuilder.group_by_capability(list) == [%{capability: "A", data: [7,3]}]
  end

  test "group multiple capability multiple dimension dataset" do
    list = [%{capability: "A", data: [5,1,2]}, %{capability: "A", data: [2,2,4]}, %{capability: "B", data: [1,2,3]}]
    assert OverviewBuilder.group_by_capability(list) == [%{capability: "A", data: [7,3,6]}, %{capability: "B", data: [1,2,3]}]
  end
end
