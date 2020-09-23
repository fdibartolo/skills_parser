defmodule Utils do
  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls
    |> elem(1) 
    |> Enum.filter(fn(f) -> String.ends_with?(f, extension) end)
  end
end