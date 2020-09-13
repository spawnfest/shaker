defmodule Shaker.MixProject do
  use Mix.Project

  @app :shaker
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases() do
    [
      build: [&build_releases/1],
      reinstall: ["build", &reinstall_archive/1]
    ]
  end

  defp build_releases(_) do
    Mix.env(:prod)
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Archive.Build.run(["--output=./#{@app}-archive/#{@app}-#{@version}.ez"])
    File.cp("./#{@app}-archive/#{@app}-#{@version}.ez", "./#{@app}-archive/#{@app}.ez")
  end

  defp reinstall_archive(_) do
    Mix.Tasks.Archive.Install.run(["#{@app}-archive/#{@app}.ez", "--force"])
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:credo,    "~> 1.1",   only: :dev, runtime: false}
    ]
  end
end
