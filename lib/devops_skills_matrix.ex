defmodule DevopsSkillsMatrix do
  def process, do: process(File.cwd)
  def process({:ok, path}), do: process(path)

  def process(path) do
    path
    |> Utils.get_files
    |> parse(Map.new)
  end

  def parse([], acc), do: acc
  def parse([file|files], acc) do
    parse files, Map.put(acc, file, "foo")
  end
end
