defmodule Shaker.Parsers.Common do

  @moduledoc """
  Common functions for Parsers
  """

  def read_from(root_path, wildcard) do
    root_path
    |> Path.join(wildcard)
    |> Path.wildcard()
    |> Enum.filter(fn x -> not (x =~ "/deps/") end)
    |> case do
      [] ->
        {:error, :bad_file}

      paths ->
        paths
        |> select_from_many()
        |> :file.consult()
    end
  end

  def stringify_values(keyword) do
    Enum.map(keyword, fn {k, v} ->
      if is_list(v) and List.ascii_printable?(v) do
        {k, to_string(v)}
      else
        {k, v}
      end
    end)
  end

  @spec select_from_many([Path.t()]) :: Path.t()
  defp select_from_many([path]), do: path
  defp select_from_many(paths) do
    Mix.shell().info("")
    paths
    |> Enum.with_index()
    |> Enum.each(fn {path, index} ->
      Mix.shell().info("#{index} #{path}")
    end)
    {index, _} =
      Mix.shell().prompt("Please select right path (Enter number)> ")
      |> Integer.parse()

    Enum.at(paths, index)
  end
end
