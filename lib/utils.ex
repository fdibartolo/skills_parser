defmodule Utils do
  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls
    |> elem(1) 
    |> Enum.filter(fn f -> String.ends_with?(f, extension) end)
    |> Enum.map(fn f -> Path.join(path, f) end)
  end

  def create_file(content, name), do: File.write(name, content)

  def purge(list) do
    list
    |> Enum.map(fn s -> String.trim s end)
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.reject(fn s -> !String.match?(s, ~r/.,\d/) end)
  end
end