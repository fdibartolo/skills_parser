defmodule DrilldownBuilder do
  @experiences ~w(Desconozco Familiarizado Usado Experto)
  @pretty_print %{ "IaC" => "Infra as Code", "SourceControl" => "Source Control" }

  def build([], acc), do: acc |> group_by_capability
  def build([set|sets], acc), do: build(sets, acc ++ [build(set)])
  defp build(set) do
    s = set |> normalize
    Map.new(name: s.capability, categories: aggregate_areas(s.areas, []))
  end

  def normalize(set) do
    normalized_areas = Utils.valid_areas_and_skills
      |> Map.keys
      |> Enum.reduce([], fn a, acc -> acc ++ [find(a, Enum.find(set.areas, fn ar -> ar.area == a end))] end) 
    Map.new(name: set.name, capability: set.capability, areas: normalized_areas)
  end

  defp find(area_name, nil), do: %{area: area_name, skills: []}
  defp find(area_name, area), do: %{area: area_name, skills: area.skills}
    
  def aggregate_areas([], acc), do: acc
  def aggregate_areas([area|areas], acc), do: aggregate_areas(areas, acc ++ [aggregate_areas(area)])

  def aggregate_areas(%{area: area, skills: skills}) do
    dataset = group_skills(area, skills)
      |> Enum.reduce([], fn {_k,v}, acc -> [v] ++ acc end)
      |> Utils.transpose
      |> Enum.with_index
      |> Enum.map(&%{data: elem(&1,0) |> Enum.reverse, label: @experiences |> Enum.at(elem(&1,1))})

    Map.new(
      name: @pretty_print |> Map.get(area, area),
      labels: Utils.valid_areas_and_skills |> Map.get(area) |> Enum.sort, 
      dataset: dataset
    )
  end

  def group_skills(area, skills) do
    skills_to_map = skills |> Enum.reduce(%{}, fn x, acc -> Map.merge(x, acc) end)
    skills_name = Utils.valid_areas_and_skills |> Map.get(area)
    experience_by_skill = skills_name |> Enum.reduce([], fn f, acc -> [Map.get(skills_to_map,f,0)] ++ acc end) |> Enum.reverse
    accumulator = skills_name |> Enum.reduce(%{}, fn x, a -> Map.merge(%{x => [0,0,0,0]}, a) end)

    skills_name
    |> Enum.reduce(accumulator, fn s, acc -> 
      Map.update!(acc, s, fn cv -> 
        add_experience(Enum.at(experience_by_skill, Enum.find_index(skills_name, &(&1==s))), cv) end) end)
  end

  def add_experience(experience, acc) do
    sum = case experience do
      2 -> [0,1,0,0]
      3 -> [0,0,1,0]
      4 -> [0,0,0,1]
      _ -> [1,0,0,0] # 0 or 1
    end
    [sum] ++ [acc] |> Utils.transpose |> Utils.reduce
  end

  def group_by_capability(list) do
    list
    |> Enum.group_by(&(&1.name))
    |> Enum.map(fn {k,v} -> %{name: k, responses: Enum.count(v), categories: v |> aggregate_categories } end)
  end

  defp aggregate_categories(list) do
    list
    |> Enum.map(&(&1.categories)) |> List.flatten 
    |> Enum.group_by(&(&1.name))
    |> Enum.map(fn {a,d} -> aggregate_datasets(a,d) end)
    |> Enum.map(fn {a,d,l} -> %{name: a, labels: l, dataset: d} end)
  end

  defp aggregate_datasets(area, list) do
    datasets=list
    |> Enum.reduce([], fn f, acc -> acc ++ f.dataset end)
    |> Enum.group_by(&(&1.label))
    |> Enum.map(fn {l,d} -> {l, d |> Enum.map(&(&1.data)) |> Utils.transpose |> Utils.reduce} end)
    |> Enum.map(fn {l,d} -> %{data: d, label: l} end)
    |> sort_experiences

    {area, datasets, list |> List.first |> Map.fetch!(:labels)}
  end

  def sort_experiences(set), do: @experiences |> Enum.map(fn e -> Enum.find(set, &(&1.label == e)) end)
end
