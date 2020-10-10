defmodule OverviewBuilderTest do
  use ExUnit.Case

  describe "build" do
    test "should handle empty list" do
      assert OverviewBuilder.build([], []) == []
    end

    test "should aggregate skills by area in single dataset" do
      content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}, %{area: "Scripting", skills: [%{"Bash" => 2}, %{"Ruby" => 1}]}], capability: "A"}]
      assert OverviewBuilder.build(content,[]) == [%{capability: "A", data: [0,0,25,0,19,0], total: 1}]
    end

    test "should aggregate skills by area in multiple dataset" do
      content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}], capability: "A"}, %{areas: [%{area: "IaC", skills: [%{"Chef" => 1}, %{"Puppet" => 1}]}], capability: "A"}]
      assert OverviewBuilder.build(content,[]) == [%{capability: "A", data: [0,0,18,0,0,0], total: 2}]
    end

    test "should ignore unknown areas" do
      content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}], capability: "A"}, %{areas: [%{area: "Testing", skills: [%{"s1" => 1}, %{"s2" => 1}]}], capability: "A"}]
      assert OverviewBuilder.build(content,[]) == [%{capability: "A", data: [0,0,13,0,0,0], total: 2}]
    end

    test "should ignore unknown skills" do
      content = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"s2" => 3}]}, %{area: "Scripting", skills: [%{"s1" => 1}, %{"Python" => 3}, %{"Ruby" => 1}]}], capability: "A"}]
      assert OverviewBuilder.build(content,[]) == [%{capability: "A", data: [0,0,10,0,25,0], total: 1}]
    end
  end

  describe "group by capability" do
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

  describe "converting to percentage" do
    test "single capability" do
      list = [%{capability: "A", data: [191,213,133,82,145,169], total: 15}]
      assert OverviewBuilder.to_percentage(list) == [%{capability: "A", data: [53,71,44,23,60,70], total: 15}]
    end
    test "multiple capability" do
      list = [%{capability: "A", data: [191,213,133,82,145,169], total: 15}, %{capability: "B", data: [104,123,103,182,80,69], total: 9}]
      assert OverviewBuilder.to_percentage(list) == [%{capability: "A", data: [53,71,44,23,60,70], total: 15}, %{capability: "B", data: [48,68,57,84,56,48], total: 9}]
    end
  end
end
