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
    mix parser "./path/to/files"
  ```
  The result of the parsing is dump into 'output.json' file
  """
  def run([path]) do
    {:ok, _} = Application.ensure_all_started(:xlsxir)

    case File.dir? path do
      false -> IO.puts "#{red()}the given path '#{path}' is not valid.#{reset()}"
      true -> 
        IO.puts "#{yellow()}parsing files within '#{path}'...#{reset()}"
        path |> DevopsSkillsMatrix.process
        IO.puts "#{green()}done! find parsed results in 'output.json'.#{reset()}"
    end
  end
end