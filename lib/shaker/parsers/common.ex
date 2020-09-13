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
      [path] -> :file.consult(path)
      _ -> {:error, :bad_file}
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
end
