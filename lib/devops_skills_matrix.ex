defmodule DevopsSkillsMatrix do
  @sheet_number 1
  @eid_cell "C5"
  @skills_col "M"

  def process, do: process(File.cwd)
  def process({:ok, path}), do: process(path)

  def process(path) do
    path
    |> Utils.get_files
    |> parse([])
    |> Poison.encode!
    |> Utils.create_output_file
  end

  def parse([], acc), do: acc
  def parse([file|files], acc) do
    parse files, acc ++ [parse(file)]
  end

  defp parse(file) do
    {:ok, spreadsheet} = Xlsxir.extract(file, @sheet_number)
    name = Xlsxir.get_cell(spreadsheet, @eid_cell)
    skills = Xlsxir.get_col(spreadsheet, @skills_col)
      |> Utils.purge
      |> split_tech_and_expertise
    Map.new(name: name, skills: skills)
  end

  def split_areas(skills), do: split_areas(skills, [])
  defp split_areas([], acc), do: acc
  defp split_areas([skill|skills], acc) do
    [a|t] = skill |> String.split(",")
    area = Enum.find(acc, fn f -> f.area == a end)
    tech = t |> Enum.join(",")
    case area do
      nil -> split_areas(skills, acc ++ [Map.new(area: a, skills: [tech])])
      _ -> split_areas(skills, [area |> Map.update!(:skills, &(&1 ++ [tech]))])
    end
  end

  def split_tech_and_expertise(skills) do
    %{
      skills |> Enum.drop(-1) |> Enum.join(",") => 
      skills |> Enum.at(-1) |> String.to_integer
    }
  end
end
