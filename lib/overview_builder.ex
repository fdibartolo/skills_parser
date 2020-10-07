defmodule OverviewBuilder do
  @valid_areas ~w(SourceControl Development Scripting IaC Containers Orchestrators)

  def build([], acc), do: acc |> group_by_capability
  def build([set|sets], acc), do: build(sets, acc ++ [build(set)])
  defp build(set) do
    case Enum.reject(set.areas, fn x -> x.area not in @valid_areas end) do
      [] -> nil
      _ -> dataset=set.areas
        |> Enum.reduce([], fn x, acc -> [aggregate(x.skills)] ++ acc end)
        Map.new(capability: "DevOps", data: Enum.reverse(dataset))
    end
  end

  defp aggregate(skills), do: skills |> Enum.reduce(0, fn x, acc -> (x |> Map.values |> List.first) + acc end)

  def group_by_capability(list) do
    list
    |> Enum.reject(fn x -> is_nil(x) end)
    |> Enum.group_by(&(&1.capability))
    |> Enum.map(fn {k,v} -> %{capability: k, data: v |> Enum.map(&(&1.data)) |> transpose |> reduce } end)
  end

  defp transpose(list), do: list |> List.zip |> Enum.map(&Tuple.to_list/1)
  defp reduce(list), do: list |> Enum.map(&Enum.sum/1)
end
