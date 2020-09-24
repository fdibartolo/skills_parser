defmodule DevopsSkillsMatrix do
  @sheet_number 1
  @eid_cell "C5"
  @skills_col "M"

  def process, do: process(File.cwd)
  def process({:ok, path}), do: process(path)

  def process(path) do
    path
    |> Utils.get_files
    |> parse(Map.new)
    |> Poison.encode!
    |> Utils.create_output_file
  end

  def parse([], acc), do: acc
  def parse([file|files], acc) do
    parse files, Map.merge(acc, parse(file))
  end

  defp parse(file) do
    {:ok, spreadsheet} = Xlsxir.extract(file, @sheet_number)
    name = Xlsxir.get_cell(spreadsheet, @eid_cell)
    skills = Xlsxir.get_col(spreadsheet, @skills_col)
    Map.new([{name, skills}])
  end
end
