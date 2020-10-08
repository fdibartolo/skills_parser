defmodule OverviewBuilderTest do
  use ExUnit.Case

  test "should handle empty list" do
    assert OverviewBuilder.build([], []) == []
  end

  test "should aggregate skills by area in single dataset" do
    content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}, %{area: "Scripting", skills: [%{"Bash" => 2}, %{"Ruby" => 1}]}]}]
    assert OverviewBuilder.build(content,[]) == [%{capability: "DevOps", data: [0,0,5,0,3,0], total: 1}]
  end

  test "should aggregate skills by area in multiple dataset" do
    content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}]}, %{areas: [%{area: "IaC", skills: [%{"Chef" => 1}, %{"Puppet" => 1}]}]}]
    assert OverviewBuilder.build(content,[]) == [%{capability: "DevOps", data: [0,0,7,0,0,0], total: 2}]
  end

  test "should ignore unknown areas" do
    content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}]}, %{areas: [%{area: "Testing", skills: [%{"s1" => 1}, %{"s2" => 1}]}]}]
    assert OverviewBuilder.build(content,[]) == [%{capability: "DevOps", data: [0,0,5,0,0,0], total: 2}]
  end

  test "should ignore unknown skills" do
    content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"s2" => 3}]}, %{area: "Scripting", skills: [%{"s1" => 1}, %{"Python" => 3}, %{"Ruby" => 1}]}]}]
    assert OverviewBuilder.build(content,[]) == [%{capability: "DevOps", data: [0,0,2,0,4,0], total: 1}]
  end

  test "group single capability single dimension dataset" do
    list = [%{capability: "A", data: [5]}, %{capability: "A", data: [2]}]
    assert OverviewBuilder.group_by_capability(list) == [%{capability: "A", data: [7], total: 2}]
  end
  
  test "group single capability multiple dimension dataset" do
    list = [%{capability: "A", data: [5,1]}, %{capability: "A", data: [2,2]}]
    assert OverviewBuilder.group_by_capability(list) == [%{capability: "A", data: [7,3], total: 2}]
  end

  test "group multiple capability multiple dimension dataset" do
    list = [%{capability: "A", data: [5,1,2]}, %{capability: "A", data: [2,2,4]}, %{capability: "B", data: [1,2,3]}]
    assert OverviewBuilder.group_by_capability(list) == [%{capability: "A", data: [7,3,6], total: 2}, %{capability: "B", data: [1,2,3], total: 1}]
  end
end
