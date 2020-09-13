defmodule Mix.Tasks.Rebar2mix do
  use Mix.Task

  @shortdoc "Generates mix.exs from rebar project"
  @moduledoc """
  Generates mix.exs from rebar project
  TODO
  """

  alias Shaker.Model.Mix, as: Model
  alias Shaker.Generator.Mix, as: Generator
  alias Shaker.Renderer

  def run(args) do
    # TODO: Create an entrypoint

    filename = "test_mix.exs"
    root_path = "priv/hackney"

    Mix.shell().info("Starting generation")

    model = %Model{}

    Mix.shell().info("Model created, filling...")
    model =
      model
      |> Shaker.Parsers.AppSrc.parse(root_path)
      |> Shaker.Parsers.RebarConfig.parse(root_path)
      |> ensure_dialyzer()

    Mix.shell().info("Model filling, writing...")
    name = mix_project_name(model)
    quoted = Generator.gen(name, model)

    IO.puts Macro.to_string(quoted)
    Renderer.render(quoted, filename)

    Mix.shell().info("Model written, formatting...")

    Mix.Task.run("format", [filename])

    Mix.shell().info("Have fun ;3")
  end

  defp mix_project_name(%{project: project}) do
    project
    |> Keyword.fetch!(:app)
    |> Keyword.fetch!(:"$anyenv")
    |> Atom.to_string()
    |> Macro.camelize()
    |> String.to_atom()
  end

  defp ensure_dialyzer(%{project: project} = model) do
    case Keyword.fetch(project, :dialyzer) do
      :error ->
        model

      {:ok, _} ->
        Model.append(model, :deps, :dialyxir, "~> 1.0.0")
    end
  end

end
