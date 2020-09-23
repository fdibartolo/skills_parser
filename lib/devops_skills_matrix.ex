defmodule DevopsSkillsMatrix do
  def process, do: process(File.cwd)
  def process({:ok, path}), do: process(path)

  def process(path) do
    path
    |> Utils.get_files
  end

  def parse([]), do: {}
end
