defmodule Utils do
  @output_file "./output.json"

  def get_files(path, extension \\ ".xlsx") do
    path 
    |> File.ls
    |> elem(1) 
    |> Enum.filter(fn f -> String.ends_with?(f, extension) end)
    |> Enum.map(fn f -> Path.join(path, f) end)
  end

  def create_output_file(content), do: File.write(@output_file, content)

  def purge(list) do
    list
    |> Enum.map(fn s -> String.trim s end)
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.reject(fn s -> !String.match?(s, ~r/.,\d/) end)
  end
end