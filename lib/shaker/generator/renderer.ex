defmodule Shaker.Generator.Renderer do

  @moduledoc """
  Macro.to_string/2 works really bad, so it should be rewritten somehow

  This module is not ready yet
  """

  @no_wrap_funcs ~w(def defmodule)a

  def render_func({func, _, [signature, [do: body]]}, _) when func in @no_wrap_funcs do
    s = "#{func} #{Macro.to_string(signature)} do\n  #{Macro.to_string(body)}\nend"
    IO.puts s
    s
  end
  def render_func(quoted, string) do
    IO.inspect(quoted)
    IO.inspect(string)
    string
  end

  def debug(q) do
    Macro.to_string(q, &render_func/2)
    |> IO.puts
  end

end
