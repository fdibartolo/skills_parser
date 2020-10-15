defmodule OverviewBuilder do
  def build([], acc), do: acc |> group_by_capability |> to_percentage
  def build([set|sets], acc), do: build(sets, acc ++ [build(set)])
  defp build(set) do
    dataset = Utils.valid_areas_and_skills
      |> Map.keys
      |> Enum.reduce([], fn va, acc -> 
        [set.areas |> Enum.find(fn s -> s.area == va end) |> aggregate] ++ acc end) 
    Map.new(capability: set.capability, data: Enum.reverse(dataset))
  end

  defp aggregate(nil), do: 0
  defp aggregate(area) do
    area.skills
    |> Enum.reduce(0, fn x, acc -> 
      case (Map.keys(x) |> List.first) in Map.fetch!(Utils.valid_areas_and_skills, area.area) do
        true -> (Map.values(x) |> List.first) + acc
        _ -> acc
      end
    end)
  end

  def group_by_capability(list) do
    list
    |> Enum.group_by(&(&1.capability))
    |> Enum.map(fn {k,v} -> 
      %{capability: k, data: v |> Enum.map(&(&1.data)) |> Utils.transpose |> Utils.reduce, total: Enum.count(v) } end)
  end

  def to_percentage(list) do
    max = Utils.valid_areas_and_skills 
      |> Map.values |> Enum.reduce([], fn f, acc -> [Enum.count(f) * 4] ++ acc end) |> Enum.reverse
    list |> to_percentage([], max)
  end

  defp to_percentage([], acc, _), do: acc
  defp to_percentage([cap|list], acc, max), do: to_percentage list, (acc ++ [to_percentage(cap, max)]), max
  defp to_percentage(cap, max) do
    max_with_headcount = max |> Enum.map(fn m -> m * cap.total end)
    p = [max_with_headcount] ++ [cap.data] 
      |> Utils.transpose |> Enum.map(fn f -> Enum.at(f,1)/Enum.at(f,0)*100 |> round end)
    Map.new(capability: cap.capability, data: p, total: cap.total)
  end
end
