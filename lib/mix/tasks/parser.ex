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
  The result of the parsing is dump into 'output.json' file
  if args are provided, will be dump into its corresponding file
  args can be:
    -o -> builds overview json file
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
        IO.puts "#{green()}done!#{reset()}"
    end
  end

  defp build_overview_file(list) do
    IO.puts "#{yellow()}building overview json file...#{reset()}"
    list |> OverviewBuilder.build([]) |> Poison.encode! |> Utils.create_file("overview.json")
  end
end