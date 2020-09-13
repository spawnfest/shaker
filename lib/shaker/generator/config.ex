defmodule Shaker.Generator.Config do

  @moduledoc """
  Generates config file from config model
  """

  @behaviour Shaker.Generator

  def gen(_, model) do
    model
    |> Enum.map(fn {{app, param}, value} ->
      value = Macro.escape(value)
      quote do
        config unquote(app), unquote(param), unquote(value)
      end
    end)
    |> to_config()
  end

  defp to_config(quoteds) do
    quote do
      import Config
      unquote_splicing(quoteds)
    end
    |> IO.inspect()
  end

end
