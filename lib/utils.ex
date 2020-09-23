defmodule Utils do
  def get_files, do: get_files(File.cwd)
  def get_files({:ok, path}), do: get_files(path)

  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls
    |> elem(1) 
    |> Enum.filter(fn(f) -> String.ends_with?(f, extension) end)
  end
end