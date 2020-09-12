defmodule Shaker.Parsers.Common do

  def read_from(root_path, wildcard) do
    case Path.wildcard(Path.join(root_path, wildcard)) do
      [path] -> :file.consult(path)
      _ -> {:error, :bad_file}
    end
  end

end
