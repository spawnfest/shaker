defmodule Shaker.Renderer do
  @moduledoc """
  Renders quoted code to the file
  """

  @spec render(Macro.t(), Path.t()) :: :ok
  def render(quoted, file_name) do
    File.write!(file_name, Macro.to_string(quoted))
  end

end
