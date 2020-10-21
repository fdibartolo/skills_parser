defmodule ToolsBuilderTest do
  use ExUnit.Case

  describe "build" do
    test "should handle empty list" do
      assert ToolsBuilder.build([]) |> is_map
    end

    test "should include all expected labels" do
      assert ToolsBuilder.build([]) |> Map.keys == [:dataset, :labels, :tools]
    end

    test "should group people count by tool for single capability" do
      sets = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}], capability: "A"}]
      result = ToolsBuilder.build(sets) |> Map.fetch!(:dataset)
      assert result |> Enum.member?(%{
          tool: "IaC - Chef",
          people: [
            %{title: "Desconozco", data: [0]},
            %{title: "Experto", data: [0]},
            %{title: "Familiarizado", data: [1]},
            %{title: "Usado", data: [0]}
          ]
        })
      assert result |> Enum.member?(%{
          tool: "IaC - Puppet",
          people: [
            %{title: "Desconozco", data: [0]},
            %{title: "Experto", data: [0]},
            %{title: "Familiarizado", data: [0]},
            %{title: "Usado", data: [1]}
          ]
        })
    end

    test "should group people count by tool for multiple capability" do
      sets = [%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 1}]}], capability: "A"},%{areas: [%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}], capability: "A"},%{areas: [%{area: "IaC", skills: [%{"Chef" => 4}, %{"Puppet" => 3}]}], capability: "B"}]
      result =  ToolsBuilder.build(sets)  |> Map.fetch!(:dataset)
      assert result |> Enum.member?(%{
          tool: "IaC - Chef",
          people: [
            %{title: "Desconozco", data: [0,0]},
            %{title: "Experto", data: [0,1]},
            %{title: "Familiarizado", data: [2,0]},
            %{title: "Usado", data: [0,0]}
          ]
        })
      assert result |> Enum.member?(%{
          tool: "IaC - Puppet",
          people: [
            %{title: "Desconozco", data: [1,0]},
            %{title: "Experto", data: [0,0]},
            %{title: "Familiarizado", data: [0,0]},
            %{title: "Usado", data: [1,1]}
          ]
        })
    end
  end

  describe "aggretate people" do
    test "should add count to corresponding experience for single skill" do
      assert ToolsBuilder.aggregate_people(%{"Puppet" => 3}, "IaC") == %{skill: "IaC - Puppet", data: [0,0,1,0]}
    end

    test "should add count to corresponding experience for multiple but different skills" do
      assert ToolsBuilder.aggregate_people([%{"Puppet" => 3}, %{"Chef" => 2}], "IaC",[]) == [
        %{skill: "IaC - Chef", data: [0,1,0,0]},
        %{skill: "IaC - Puppet", data: [0,0,1,0]}
      ]
    end

    test "should add count to corresponding experience for multiple but same skills" do
      assert ToolsBuilder.aggregate_people([%{"Puppet" => 3}, %{"Chef" => 2}, %{"Chef" => 1}, %{"Puppet" => 3}], "IaC", []) == [
        %{skill: "IaC - Chef", data: [1,1,0,0]},
        %{skill: "IaC - Puppet", data: [0,0,2,0]}
      ]
    end
  end

  describe "list of tools" do
    test "should combine category and list into single list" do
      list = %{"foo" => ~w(t1 t2), "bar" => ~w(t1)}
      assert ToolsBuilder.build_tools(list) == ["bar - t1", "foo - t1", "foo - t2"]
    end
  end

  describe "list of labels" do
    test "should include all capabalities" do
      sets = [%{name: "foo", capability: "A", areas: []}, %{name: "bar", capability: "A", areas: []}, %{name: "baz", capability: "B", areas: []}]
      assert ToolsBuilder.build_labels(sets) == ["A", "B"]
    end
  end

  describe "unlisted skills" do
    test "should be merged as 'Desconozco'" do
      list = [%{data: [0,1,0,0], skill: "IaC - Chef"},%{data: [1,0,1,0], skill: "IaC - Puppet"}]
      result = ToolsBuilder.merge_unlisted_skills(list, 3)
      assert result |> Enum.member?(%{data: [2,1,0,0], skill: "IaC - Chef"})
      assert result |> Enum.member?(%{data: [2,0,1,0], skill: "IaC - Puppet"})
    end    
  end
end
