defmodule Utils do
  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls!
    |> Enum.filter(&String.ends_with?(&1, extension))
    |> Enum.map(&Path.join(path, &1))
  end

  def get_dirs(path), do: path |> File.ls! |> Enum.map(&Path.join(path,&1)) |> Enum.filter(&File.dir?&1)    

  def create_file(content, name), do: File.write(name, content)

  def purge(list) do
    list
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reject(&!String.match?(&1, ~r/.,\d/))
  end

  def transpose(list), do: list |> List.zip |> Enum.map(&Tuple.to_list/1)
  def reduce(list), do: list |> Enum.map(&Enum.sum/1)
end