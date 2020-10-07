defmodule OverviewBuilder do
  def build([], acc), do: acc |> group_by_capability
  def build([set|sets], acc), do: build(sets, acc ++ [build(set)])
  defp build(set) do
    dataset=set.areas
    |> Enum.reduce([], fn x, acc -> [aggregate(x.skills)] ++ acc end)
    Map.new(capability: "DevOps", data: Enum.reverse(dataset))
  end

  defp aggregate(skills), do: skills |> Enum.reduce(0, fn x, acc -> (x |> Map.values |> List.first) + acc end)

  def group_by_capability(list) do
    list
    |> Enum.group_by(&(&1.capability))
    |> Enum.map(fn {k,v} -> %{capability: k, data: v |> Enum.map(&(&1.data)) |> transpose |> reduce } end)
  end

  defp transpose(list), do: list |> List.zip |> Enum.map(&Tuple.to_list/1)
  defp reduce(list), do: list |> Enum.map(&Enum.sum/1)
end
