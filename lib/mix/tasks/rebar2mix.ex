defmodule Mix.Tasks.Rebar2mix do
  use Mix.Task

  @shortdoc "Generates mix.exs from rebar project"
  @moduledoc """
  Generates mix.exs from rebar project
  TODO
  """

  @option_parser_params [strict: [apps_root: :string, in_umbrella: :boolean]]
  @default_params %{in_umbrella: false}

  alias Shaker.Model.Mix, as: Model
  alias Shaker.Generator.Mix, as: Generator
  alias Shaker.Renderer

  defp parse(args) do
    with(
      {parsed_params, argv, []} <- OptionParser.parse(args, @option_parser_params),
      {:ok, argv} <- ensure_argv(argv)
    ) do
      {:ok, Map.merge(@default_params, Map.new(parsed_params)), argv}
    else
      _ -> {:error, :bad_params}
    end
  end

  defp ensure_argv([]), do: {:ok, [".", "mix.exs"]}
  defp ensure_argv([root]), do: {:ok, [root, "mix.exs"]}
  defp ensure_argv([_, _] = x), do: {:ok, x}
  defp ensure_argv(_), do: :error

  def run(args) do
    {opts, root_path, filename} =
      case parse(args) do
        {:ok, opts, [root_path, filename]} ->
          {opts, root_path, filename}

        _ ->
          Mix.raise("Bad params. Refer to `mix help rebar2mix`")
      end
      |> IO.inspect(label: :args)
    call(root_path, filename, opts)
  end

  def call(root_path, filename, opts) do
    model =
      %Model{}
      |> Shaker.Parsers.AppSrc.parse(root_path)
      |> Shaker.Parsers.RebarConfig.parse(root_path)
      |> Model.put(:language, :erlang)
      |> ensure_dialyzer()
      |> ensure_umbrella(root_path)
      |> apply_opts(opts)
      |> Shaker.Errors.render()

    model
    |> mix_project_name(root_path)
    |> Generator.gen(model)
    |> Renderer.render(filename)

    Mix.Task.run("format", [filename, "**/mix.exs"])

    Mix.shell().info("Done")
  end

  defp ensure_umbrella(model, root_path) do
    if umbrella?(root_path) and Mix.shell().yes?("""
    Umbrella support is experimental and may be unstable, proceed?
    """) do
      call_for_apps(root_path)
      Model.put(model, :apps_path, "apps")
    else
      model
    end
  end

  defp apply_opts(model, opts) do
    Enum.reduce(opts, model, fn
      {:in_umbrella, true}, model ->
        add_in_umbrella(model)

      _, model ->
        model
    end)
  end

  defp call_for_apps(root_path) do
    root_path
    |> Path.join("apps/*")
    |> Path.wildcard()
    |> Enum.each(fn path ->
      mixexs = Path.join(path, "mix.exs")
      Mix.shell().info("Calling rebar2mix for project at #{path}")
      call(path, mixexs, %{in_umbrella: true})
    end)
  end

  defp add_in_umbrella(model) do
    Model.put_pairs(model, [
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
    ])
  end

  defp mix_project_name(%{project: project}, root_path) do
    if umbrella?(root_path) do
      :"#{Mix.shell().prompt("Enter mix project name> ")}"
    else
      project
      |> Keyword.fetch!(:app)
      |> Keyword.fetch!(:"$anyenv")
      |> Atom.to_string()
      |> Macro.camelize()
      |> String.to_atom()
    end
  end

  defp ensure_dialyzer(%{project: project} = model) do
    case Keyword.fetch(project, :dialyzer) do
      :error ->
        model

      {:ok, _} ->
        Model.append(model, :deps, :dialyxir, "~> 1.0.0")
    end
  end

  @spec umbrella?(project_root_path :: Path.t()) :: boolean()
  defp umbrella?(project_root_path) do
    project_root_path
    |> Path.join("apps")
    |> Path.expand()
    |> File.dir?()
  end

end
