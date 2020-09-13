defmodule Shaker.Resolver.Deps do

  @moduledoc """
  Module to convert rebar deps to mix deps
  """

  def convert(dep_name) when is_atom(dep_name) do
    {:ok, {dep_name, ">= 0.0.0"}}
  end

  def convert({dep_name, dep_version}) when is_atom(dep_name) and is_list(dep_version) do
    case Version.parse_requirement("#{dep_version}") do
      {:ok, requirement} ->
        {:ok, {dep_name, "#{requirement}"}}

      :error ->
        case Version.parse("#{dep_version}") do
          {:ok, version} -> {:ok, {dep_name, "== #{version}"}}
          :error -> {:error, {:deps, :parse, {dep_name, dep_version}}}
        end
    end
  end

  # Source dependencies

  # Git
  def convert({dep_name, {:git, repo_url}}) when is_atom(dep_name) do
    {:ok, {dep_name, [{:git, "#{repo_url}"}]}}
  end

  def convert({dep_name, {:git, repo_url, {ref_type, ref_value}}}) when is_atom(dep_name) do
    {:ok, {dep_name, [{:git, "#{repo_url}"}, {ref_type, "#{ref_value}"}]}}
  end

  def convert({dep_name, {:git_subdir, repo_url, {ref_type, ref_value}, subdir_path}})
      when is_atom(dep_name) do
    {:ok,
     {dep_name, [{:git, "#{repo_url}"}, {ref_type, "#{ref_value}"}, {:sparse, "#{subdir_path}"}]}}
  end

  # Hg is not supported
  def convert({dep_name, {:hg, _}}) when is_atom(dep_name) do
    {:error, {:deps, :hg, dep_name}}
  end

  # HG with refs
  def convert({dep_name, {:hg, _, _}}) when is_atom(dep_name) do
    {:error, {:deps, :hg, dep_name}}
  end

  def convert(dep_record) do
    case elem(dep_record, 0) do
      dep when is_atom(dep) -> {:error, {:unknown, dep}}
      _ -> {:error, {:deps, :parse, dep_record}}
    end
  end
end
