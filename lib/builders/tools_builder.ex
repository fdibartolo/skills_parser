defmodule ToolsBuilder do

  def build(sets) do
    t = Utils.valid_areas_and_skills |> build_tools
    l = sets |> build_labels
    Map.new(tools: t, labels: l, dataset: build_dataset(sets, []))
  end
  def build_dataset([], acc), do: acc
  def build_dataset([set|sets], acc), do: build_dataset(sets, acc ++ [build_dataset(set)])
  defp build_dataset(_set) do
    Map.new()
  end

  def build_tools(list) do
    list
    |> Enum.reduce([], fn {k,v}, acc -> acc ++ [Enum.map(v, &("#{k} - #{&1}"))] end)
    |> List.flatten 
  end

  def build_labels(sets), do: sets |> Enum.map(&(&1.capability)) |> Enum.uniq
end
