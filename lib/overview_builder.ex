defmodule OverviewBuilder do
  @valid_areas_and_skills %{
    "SourceControl" => ["Git", "Mercurial", "SVN", "CVS"],
    "Development" => [".Net", "Java", "Javascript/NodeJS", "Ruby", "Python"],
    "Scripting" => ["Bash", "Powershell", "Ruby", "Python"],
    "IaC" => ["CloudFormation", "Chef", "Terraform", "Puppet"],
    "Containers" => ["Openshift", "Kubernetes (standalone)", "AWS ecosystem (ECS, EKS, Fargate)", "Azure ecosystem (AKS, Service Fabric)"],
    "Orchestrators" => ["Jenkins", "Azure DevOps pipelines", "AWS stack (CodeBuild, CodePipeline, CodeDeploy)", "Spinnaker", "TeamCity"]
  }

  def build([], acc), do: acc |> group_by_capability
  def build([set|sets], acc), do: build(sets, acc ++ [build(set)])
  defp build(set) do
    case Enum.reject(set.areas, fn x -> x.area not in Map.keys(@valid_areas_and_skills) end) do
      [] -> nil
      _ -> dataset=set.areas
        |> Enum.reduce([], fn area, acc -> [aggregate(area)] ++ acc end)
        Map.new(capability: "DevOps", data: Enum.reverse(dataset))
    end
  end

  defp aggregate(area) do
    area.skills
    |> Enum.reduce(0, fn x, acc -> 
      case (Map.keys(x) |> List.first) in Map.fetch!(@valid_areas_and_skills, area.area) do
        true -> (Map.values(x) |> List.first) + acc
        _ -> acc
      end
    end)
  end

  def group_by_capability(list) do
    list
    |> Enum.reject(fn x -> is_nil(x) end)
    |> Enum.group_by(&(&1.capability))
    |> Enum.map(fn {k,v} -> %{capability: k, data: v |> Enum.map(&(&1.data)) |> transpose |> reduce } end)
  end

  defp transpose(list), do: list |> List.zip |> Enum.map(&Tuple.to_list/1)
  defp reduce(list), do: list |> Enum.map(&Enum.sum/1)
end
