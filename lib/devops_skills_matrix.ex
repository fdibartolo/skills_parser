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
    parse files, Map.merge(acc, parse(file))
  end

  defp parse(file) do
    {:ok, spreadsheet} = Xlsxir.extract(file, 0)
    name = Xlsxir.get_cell(spreadsheet, "A1")
    skills = Xlsxir.get_col(spreadsheet, "C")
    Map.new([{name, skills}])
  end
end
