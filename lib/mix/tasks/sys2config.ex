defmodule Mix.Tasks.Sys2config do
  use Mix.Task

  @shortdoc "Generates config.exs from sys.config file"
  @moduledoc """
  Generates config.exs from sys.config file

  Usage:
  ```
  $ mix rebar2mix <input_sys_config> <output_file.exs>
  ```
  """

  alias Shaker.Generator.Config, as: Generator
  alias Shaker.Renderer

  def run([]), do: run(["sys.config"])
  def run([input]), do: run([input, "config.exs"])
  def run([input, output]) do
    model = Shaker.Parsers.Sysconfig.parse(%{}, input)
    Generator.gen(nil, model)
    |> Renderer.render(output)

    Mix.Task.run("format", [output])
  end

end
