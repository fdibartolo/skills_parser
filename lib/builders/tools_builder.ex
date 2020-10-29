defmodule ToolsBuilder do
  @experiences ~w(Desconozco Familiarizado Usado Experto)

  def build(sets) do
    d = sets |> build_dataset
    t = d |> build_tools
    l = sets |> build_labels
    Map.new(tools: t, labels: l, dataset: d)
  end

  def build_dataset(sets), do: sets |> Enum.group_by(&(&1.capability)) |> Map.values |> aggregate_cap([])

  defp aggregate_cap([], acc), do: acc |> group_by_tool
  defp aggregate_cap([cap|caps], acc), do: aggregate_cap(caps, acc ++ aggregate_cap(cap))
  defp aggregate_cap(cap) do # all responses for one specific capability
    cap
    |> Enum.map(&(&1.areas)) |> List.flatten
    |> Enum.group_by(&(&1.area))
    |> Enum.map(fn {a,s} -> %{area: a, skills: Enum.reduce(s,[],&(&2 ++ &1.skills)) |> List.flatten} end)
    |> Enum.map(&(aggregate_people(&1.skills, &1.area, []))) |> List.flatten
    |> merge_unlisted_skills(cap |> Enum.count)
    |> Enum.map(&(Map.new(tools: &1.skill, people: &1.data |> Enum.with_index |> Enum.map(fn {v,i} -> %{data: List.wrap(v), title: Enum.at(@experiences,i)} end))))
  end

  def group_by_tool(list) do
    list
    |> Enum.group_by(&(&1.tools)) 
    |> Enum.map(fn {t,p} -> %{tool: t, people: p |> Enum.map(&(&1.people)) |> merge} end)
  end

  defp merge(list) do
    list
    |> List.flatten 
    |> Enum.group_by(&(&1.title)) 
    |> Enum.map(fn {k,v} -> %{title: k, data: Enum.map(v, &(&1.data)) |> Enum.reduce([],&(&1 ++ &2)) |> Enum.reverse} end)
  end

  def aggregate_people([], _, acc), do: acc |> aggregate_skills
  def aggregate_people([skill|skills], area, acc), do: aggregate_people(skills, area, acc ++ [aggregate_people(skill, area)])
  def aggregate_people(skill, area) do
    Map.new(
      skill: "#{area} - #{skill |> Map.keys |> List.first}", 
      data: case skill |> Map.values |> List.first do
        2 -> [0,1,0,0]
        3 -> [0,0,1,0]
        4 -> [0,0,0,1]
        _ -> [1,0,0,0] # 0 or 1
      end
    )
  end

  defp aggregate_skills(list) do
    list
    |> Enum.group_by(&(&1.skill))
    |> Enum.map(fn {k,v} -> %{skill: k, data: Enum.map(v, &(&1.data)) |> Utils.transpose |> Utils.reduce} end)
  end

  def merge_unlisted_skills(list, count) do
    default_skills=Utils.valid_areas_and_skills
    |> Enum.reduce([], fn {k,v}, acc -> acc ++ [Enum.map(v, &("#{k} - #{&1}"))] end)
    |> List.flatten 
    |> Enum.map(fn s -> merge_unlisted_skill(s, count, list |> Enum.find(&(&1.skill == s))) end)

    Enum.map(list,&(&1.skill)) -- Enum.map(default_skills,&(&1.skill))
    |> Enum.map(&(Enum.find(list,fn f -> f.skill == &1 end)))
    |> Enum.concat(default_skills)
  end

  defp merge_unlisted_skill(skill, count, nil), do: Map.new(skill: skill, data: [count,0,0,0])
  defp merge_unlisted_skill(skill, count, skillset) do
    responses = skillset.data |> Enum.sum
    Map.new(skill: skill, data: [[count-responses,0,0,0]] ++ [skillset.data] |> Utils.transpose |> Utils.reduce)
  end

  def build_tools(list), do: list |> Enum.map(&(&1.tool))

  def build_labels(sets), do: sets |> Enum.map(&(&1.capability)) |> Enum.uniq |> Enum.sort
end
