defmodule OverviewBuilder do
  @valid_areas_and_skills %{
    "Containers" => ["Docker / Docker Swarm", "Openshift", "Kubernetes (standalone)", "AWS ecosystem (ECS, EKS, Fargate)", "Google Cloud ecosystem (Registry, GKE)", "Azure ecosystem (AKS, Service Fabric)"],
    "Development" => [".Net", "Java", "Javascript/NodeJS", "Ruby", "Python"],
    "IaC" => ["Ansible", "CloudFormation", "Chef", "Terraform", "Puppet"],
    "Orchestrators" => ["Jenkins", "Azure DevOps pipelines", "AWS stack (CodeBuild, CodePipeline, CodeDeploy)", "Google Cloud Build", "Spinnaker", "TeamCity"],
    "Scripting" => ["Bash", "Powershell", "Ruby", "Python"],
    "SourceControl" => ["Git", "Mercurial", "SVN", "CVS"]
  }

  def build([], acc), do: acc |> group_by_capability
  def build([set|sets], acc), do: build(sets, acc ++ [build(set)])
  defp build(set) do
    dataset = @valid_areas_and_skills
      |> Map.keys
      |> Enum.reduce([], fn va, acc -> 
        [set.areas |> Enum.find(fn s -> s.area == va end) |> aggregate] ++ acc end) 
    Map.new(capability: "DevOps", data: Enum.reverse(dataset))
  end

  defp aggregate(nil), do: 0
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
    |> Enum.group_by(&(&1.capability))
    |> Enum.map(fn {k,v} -> %{capability: k, data: v |> Enum.map(&(&1.data)) |> transpose |> reduce } end)
  end

  defp transpose(list), do: list |> List.zip |> Enum.map(&Tuple.to_list/1)
  defp reduce(list), do: list |> Enum.map(&Enum.sum/1)
end
