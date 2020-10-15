defmodule DrilldownBuilderTest do
  use ExUnit.Case

  describe "add experience" do
    test "should add to second level (Familiarizado)" do
      assert DrilldownBuilder.add_experience(1, [3,1,5,7]) == [3,2,5,7]
    end

    test "should add to fourth level (Experto)" do
      assert DrilldownBuilder.add_experience(3, [3,1,5,7]) == [3,1,5,8]
    end
  end

  describe "group skills" do
    test "should merge skills experience" do
      assert DrilldownBuilder.group_skills("IaC", [%{"Ansible" => 1}, %{"Chef" => 2}, %{"Puppet" => 3}]) == %{
        "Ansible" => [0,1,0,0],
        "CloudFormation" => [1,0,0,0],
        "Chef" => [0,0,1,0],
        "Terraform" => [1,0,0,0],
        "Puppet" => [0,0,0,1]
      }
    end
  end

  describe "aggregate areas" do
    test "should merge data for a single dataset" do
      assert DrilldownBuilder.aggregate_areas(%{area: "IaC", skills: [%{"Chef" => 2}, %{"Puppet" => 3}]}) == %{
        name: "Infra as Code",
        labels: ["Ansible","Chef","CloudFormation","Puppet","Terraform"], #sorted alphabetically!!
        dataset: [
          %{data: [1,0,1,0,1], label: "Desconozco"},
          %{data: [0,0,0,0,0], label: "Familiarizado"},
          %{data: [0,1,0,0,0], label: "Usado"},
          %{data: [0,0,0,1,0], label: "Experto"}
        ]
      }
    end

    test "should merge data for a multiple dataset" do
      input = [
        %{area: "IaC", skills: [%{"Chef" => 3}, %{"Puppet" => 3}]},
        %{area: "Scripting", skills: [%{"Python" => 1}, %{"Ruby" => 3}]},
        %{area: "SourceControl", skills: [%{"Git" => 1}]}
      ]
      assert DrilldownBuilder.aggregate_areas(input, []) == [
        %{
          name: "Infra as Code",
          labels: ["Ansible","Chef","CloudFormation","Puppet","Terraform"], #sorted alphabetically!!
          dataset: [
            %{data: [1,0,1,0,1], label: "Desconozco"},
            %{data: [0,0,0,0,0], label: "Familiarizado"},
            %{data: [0,0,0,0,0], label: "Usado"},
            %{data: [0,1,0,1,0], label: "Experto"}
          ]
        },
        %{
          name: "Scripting",
          labels: ["Bash", "Powershell", "Python", "Ruby"], #sorted alphabetically!!
          dataset: [
            %{data: [1,1,0,0], label: "Desconozco"},
            %{data: [0,0,1,0], label: "Familiarizado"},
            %{data: [0,0,0,0], label: "Usado"},
            %{data: [0,0,0,1], label: "Experto"}
          ]
        },
        %{
          name: "Source Control",
          labels: ["CVS", "Git", "Mercurial", "SVN"], #sorted alphabetically!!
          dataset: [
            %{data: [1,0,1,1], label: "Desconozco"},
            %{data: [0,1,0,0], label: "Familiarizado"},
            %{data: [0,0,0,0], label: "Usado"},
            %{data: [0,0,0,0], label: "Experto"}
          ]
        }
      ]
    end
  end

  describe "normalize" do
    test "should include missing areas" do
      assert DrilldownBuilder.normalize(%{name: "foo", capability: "bar", areas: [%{area: "IaC", skills: [%{"Chef" => 3}]}, %{area: "Scripting", skills: [%{"Ruby" => 3}]}]})
        |> Map.fetch!(:areas)
        |> Enum.map(&(&1.area)) == ["Containers","Development","IaC","Orchestrators","Scripting","SourceControl"]
    end
    test "should include all areas" do
      assert DrilldownBuilder.normalize(%{name: "foo", capability: "bar", areas: []})
        |> Map.fetch!(:areas)
        |> Enum.map(&(&1.area)) == ["Containers","Development","IaC","Orchestrators","Scripting","SourceControl"]
    end
  end

  describe "build" do
    test "should handle empty list" do
      assert DrilldownBuilder.build([], []) == []
    end

    test "should include capability name" do
      assert DrilldownBuilder.build([%{name: "foo", capability: "bar", areas: []}], [])
        |> List.first |> Map.fetch!(:name) == "bar"
    end

    test "should aggregate skills by area in single dataset" do
      input = [%{areas: [%{area: "IaC", skills: [%{"Ansible" => 1}, %{"Chef" => 2}, %{"Puppet" => 3}]}], capability: "A", name: "foo"}]
      assert DrilldownBuilder.build(input,[]) |> List.first
        |> Map.fetch!(:categories) |> Enum.find(&(&1.name == "Infra as Code")) == %{
          name: "Infra as Code",
          labels: ["Ansible", "Chef", "CloudFormation", "Puppet", "Terraform"],
          dataset: [
            %{ data: [0,0,1,0,1], label: "Desconozco" },
            %{ data: [1,0,0,0,0], label: "Familiarizado" },
            %{ data: [0,1,0,0,0], label: "Usado" },
            %{ data: [0,0,0,1,0], label: "Experto" }
          ]}
    end

    test "should include all valid and pretty-printed categories" do
      assert DrilldownBuilder.build([%{name: "foo", capability: "bar", areas: []}],[])
        |> List.first |> Map.fetch!(:categories)
        |> Enum.map(&(Map.fetch!(&1,:name))) == ["Containers","Development","Infra as Code","Orchestrators","Scripting","Source Control"]
    end

    test "should include number of responses per capability" do
      sets = [%{name: "foo", capability: "A", areas: []}, %{name: "bar", capability: "A", areas: []}, %{name: "baz", capability: "B", areas: []}]
      result = DrilldownBuilder.build(sets, [])
      assert result |> Enum.count == 2
      assert result |> Enum.find(&(&1.name == "A")) |> Map.fetch!(:responses) == 2
      assert result |> Enum.find(&(&1.name == "B")) |> Map.fetch!(:responses) == 1
    end

    test "should group response data per capability" do
      sets = [%{name: "foo", capability: "A", areas: []}, %{name: "bar", capability: "A", areas: []}, %{name: "baz", capability: "B", areas: []}]
      result = DrilldownBuilder.build(sets, [])
      assert result |> Enum.find(&(&1.name == "A")) |> Map.fetch!(:categories) |> Enum.find(&(&1.name == "Infra as Code")) == %{
        name: "Infra as Code",
        labels: ["Ansible", "Chef", "CloudFormation", "Puppet", "Terraform"],
        dataset: [
          %{ data: [2,2,2,2,2], label: "Desconozco" },
          %{ data: [0,0,0,0,0], label: "Familiarizado" },
          %{ data: [0,0,0,0,0], label: "Usado" },
          %{ data: [0,0,0,0,0], label: "Experto" }
        ]}
    end
  end
end
