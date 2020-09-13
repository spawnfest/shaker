defmodule Shaker.Renderer do
  @moduledoc """
  Renders quoted code to the file
  """

  @spec render(Macro.t(), Path.t()) :: :ok
  def render(quoted, file_name) do
    string =
      quoted
      |> Macro.to_string()
      |> String.replace(~r/(defmodule|defp|def)\((.*)\) do/, "\\1 \\2 do")
      |> String.replace(~r/(defmodule|defp|def) (.*)\(\) do/, "\\1 \\2 do")
      |> String.replace(~r/(use|import|config)\((.*)\)\n/, "\\1 \\2\n")

    File.write!(file_name, string)
  end

end
