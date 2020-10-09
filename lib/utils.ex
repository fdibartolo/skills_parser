defmodule Utils do
  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls
    |> elem(1) 
    |> Enum.filter(&String.ends_with?(&1, extension))
    |> Enum.map(&Path.join(path, &1))
  end

  def create_file(content, name), do: File.write(name, content)

  def purge(list) do
    list
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reject(&!String.match?(&1, ~r/.,\d/))
  end
end