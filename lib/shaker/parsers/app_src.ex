defmodule Shaker.Parsers.AppSrc do

  @moduledoc """
  Parses app.src file
  """

  @behaviour Shaker.Parsers

  alias Shaker.Parsers.Common
  alias Shaker.Model.Mix, as: Model

  @app_src_file_wildcard "**/*.app.src"
  @autoloaded_erlang_applications ~w[kernel stdlib elixir]a

  def parse(model, root_path) do
    case Common.read_from(root_path, @app_src_file_wildcard) do
      {:ok, [{:application, name, kw}]} -> do_parse(model, name, kw)
      error -> Model.add_errors(model, [{:app_src, error}])
    end
  end

  defp do_parse(model, app_name, app_keyword) do
    Enum.reduce(
      app_keyword,
      initial_structure(model, app_name),
      &proceed_app_src_entry/2
    )
  end

  @spec initial_structure(Model.t(), app_name :: atom()) :: map()
  defp initial_structure(model, app_name) do
    model
    |> Model.put(:app, app_name)
    |> Model.put(:package, %{name: :erlang.atom_to_binary(app_name)})
  end

  defp proceed_app_src_entry({:description, description}, model) do
    Model.put(model, :description, :erlang.list_to_binary(description))
  end

  defp proceed_app_src_entry({:vsn, version} = pair, model) do
    if is_list(version) and List.ascii_printable?(version) do
      Model.put(model, :version, :erlang.list_to_binary(version))
    else
      Model.add_errors(model, [pair])
    end
  end

  defp proceed_app_src_entry({:mod, mod}, model) do
    # Mod goes as-is - basically it's a tuple
    Model.put(model, :mod, mod)
  end

  defp proceed_app_src_entry({:applications, apps}, model) do
    # applications in mix are defined as extra_applications
    Model.put(model, :extra_applications, apps -- @autoloaded_erlang_applications)
  end

  defp proceed_app_src_entry({:env, env}, model) do
    # env goes inside application data
    Model.put(model, :env, env)
  end

  defp proceed_app_src_entry({:licenses, licenses}, model) do
    # licenses goes inside project's package data
    licenses = Enum.map(licenses, &:erlang.list_to_binary/1)
    Model.update(model, :package, & Map.put(&1, :licenses, licenses), %{licenses: licenses})
  end

  defp proceed_app_src_entry({:links, links}, model) do
    # links goes inside project's package data
    links = Enum.map(links, fn {name, value} -> {"#{name}", "#{value}"} end)
    Model.update(model, :package, & Map.put(&1, :links, links), %{links: links})
  end

  # Registered goes here - it's skipped
  defp proceed_app_src_entry({:registered, _}, model), do: model
  # Modules goes here - it's skipped
  defp proceed_app_src_entry({:modules, _}, model), do: model

  # Default case - something is not known for the Shaker. Warn the user here
  defp proceed_app_src_entry(pair, model) do
    Model.add_errors(model, [{:app_src, pair}])
  end
end
