defmodule ToolsBuilder do

  def build(sets) do
    Map.new(tools: [], labels: [], dataset: build_dataset(sets, []))
  end
  def build_dataset([], acc), do: acc
  def build_dataset([set|sets], acc), do: build_dataset(sets, acc ++ [build_dataset(set)])
  defp build_dataset(_set) do
    Map.new()
  end

end
