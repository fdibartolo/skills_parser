defmodule Utils do
  @valid_areas_and_skills %{
    "Containers" => ["Docker / Docker Swarm", "Openshift", "Kubernetes (standalone)", "AWS ecosystem (ECS, EKS, Fargate)", "Google Cloud ecosystem (Registry, GKE)", "Azure ecosystem (AKS, Service Fabric)"],
    "Development" => [".Net", "Java", "Javascript/NodeJS", "Ruby", "Python"],
    "IaC" => ["Ansible", "CloudFormation", "Chef", "Terraform", "Puppet"],
    "Orchestrators" => ["Jenkins", "Azure DevOps pipelines", "AWS stack (CodeBuild, CodePipeline, CodeDeploy)", "Google Cloud Build", "Spinnaker", "TeamCity"],
    "Scripting" => ["Bash", "Powershell", "Ruby", "Python"],
    "SourceControl" => ["Git", "Mercurial", "SVN", "CVS"]
  }

  def valid_areas_and_skills, do: @valid_areas_and_skills
    
  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls!
    |> Enum.filter(&String.ends_with?(&1, extension))
    |> Enum.map(&Path.join(path, &1))
  end

  def get_dirs(path), do: path |> File.ls! |> Enum.map(&Path.join(path,&1)) |> Enum.filter(&File.dir?&1)    

  def create_file(content, name), do: File.write(name, content)

  def purge(list) do
    list
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reject(&!String.match?(&1, ~r/.,\d/))
  end

  def transpose(list), do: list |> List.zip |> Enum.map(&Tuple.to_list/1)
  def reduce(list), do: list |> Enum.map(&Enum.sum/1)
  def shorten(list), do: list |> Enum.map(&(String.split(&1)) |> List.first)
end