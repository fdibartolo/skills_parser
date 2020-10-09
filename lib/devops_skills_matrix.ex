defmodule DevopsSkillsMatrix do
  @sheet_number 1
  @eid_cell "C5"
  @skills_col "M"

  def process, do: process(File.cwd)
  def process({:ok, path}), do: process(path)

  def process(path) do
    raw = path |> Utils.get_dirs |> Enum.map(fn d -> d |> Utils.get_files |> parse([]) end)
    {:ok, raw |> List.flatten}
  end

  def parse([], acc), do: acc
  def parse([file|files], acc) do
    parse files, acc ++ [parse(file)]
  end

  defp parse(file) do
    {:ok, spreadsheet} = Xlsxir.extract(file, @sheet_number)
    name = Xlsxir.get_cell(spreadsheet, @eid_cell)
    capability = file |> Path.dirname |> String.split("/") |> List.last
    skills_by_area = Xlsxir.get_col(spreadsheet, @skills_col)
      |> Utils.purge
      |> split_areas
    Map.new(name: name, capability: capability, areas: skills_by_area)
  end

  def split_areas(skills), do: split_areas(skills, [])
  defp split_areas([], acc), do: acc
  defp split_areas([skill|skills], acc) do
    [a|t] = skill |> String.split(",")
    area = Enum.find(acc, fn f -> f.area == a end)
    tech = t |> split_tech_and_expertise
    case area do
      nil -> split_areas(skills, acc ++ [Map.new(area: a, skills: [tech])])
      _ -> split_areas(skills, merge_skills(acc, area, tech))
    end
  end

  def split_tech_and_expertise(skills), do: %{ skills |> Enum.drop(-1) |> Enum.join(",") => 
    skills |> Enum.at(-1) |> String.to_integer }

  defp merge_skills(acc, a, t), do: Enum.reject(acc, fn f -> f.area == a.area end) ++ 
    [a |> Map.update!(:skills, &(&1 ++ [t]))]
end
