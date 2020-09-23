defmodule Utils do
  @output_file "./output.json"

  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls
    |> elem(1) 
    |> Enum.filter(fn(f) -> String.ends_with?(f, extension) end)
  end

  def create_output_file(content), do: File.write(@output_file, content)
end