defmodule Mix.Tasks.Parser do
  use Mix.Task
  import IO.ANSI
  
  @shortdoc "Parse files in the given path"
  @moduledoc ~S"""
  This is used to parse all of the excel files within the given path.           
  The excel file structure is fixed, data is expected to be within that layout (out of scope here).
  Path is pass as a parameter to the task
  #Usage
  ```
    mix parser ./path/to/files [args]
  ```
  The result of the parsing is dump into 'output.json' file. 
  If args are provided, will be dump into its corresponding file. 
  ```
  args can be:

    -o -> builds overview json file
    -d -> builds drilldown json file
    -t -> builds tools json file
  ```
  """
  def run([path|args]) do
    {:ok, _} = Application.ensure_all_started(:xlsxir)

    case File.dir? path do
      false -> IO.puts "#{red()}the given path '#{path}' is not valid.#{reset()}"
      true -> 
        IO.puts "#{yellow()}parsing files within '#{path}'...#{reset()}"
        {_, raw} = path |> DevopsSkillsMatrix.process
        raw |> Poison.encode! |> Utils.create_file("output.json")
        if "-o" in args, do: raw |> build_overview_file
        if "-d" in args, do: raw |> build_drilldown_file
        if "-t" in args, do: raw |> build_tools_file
        IO.puts "#{green()}done!#{reset()}"
    end
  end

  defp build_overview_file(list) do
    IO.puts "#{yellow()}building overview json file...#{reset()}"
    list |> OverviewBuilder.build([]) |> Poison.encode! |> Utils.create_file("overview.json")
  end

  defp build_drilldown_file(list) do
    IO.puts "#{yellow()}building drilldown json file...#{reset()}"
    list |> DrilldownBuilder.build([]) |> Poison.encode! |> Utils.create_file("drilldown.json")
  end

  defp build_tools_file(list) do
    IO.puts "#{yellow()}building tools json file...#{reset()}"
    list |> ToolsBuilder.build |> Poison.encode! |> Utils.create_file("tools.json")
  end
end