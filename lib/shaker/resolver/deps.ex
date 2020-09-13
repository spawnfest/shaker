defmodule Shaker.Resolver.Deps do

  @moduledoc """
  Module to convert rebar deps to mix deps
  """

  @behaviour Shaker.Resolver

  defguardp is_git(t) when is_tuple(t) and
    ((:erlang.element(1, t) == :git) or (:erlang.element(1, t) == :git_subdir))

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
  def convert({dep_name, t}) when is_git(t) and is_atom(dep_name) do
    {:ok, {dep_name, convert_git(t)}}
  end
  def convert({dep_name, b, t}) when is_list(b) and is_git(t) and is_atom(dep_name) do
    {:ok, {dep_name, convert_git(t)}}
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
      dep when is_atom(dep) -> {:error, {:unknown_dep, dep}}
      _ -> {:error, {:deps, :parse, dep_record}}
    end
  end

  defp convert_git({:git, repo_url, {ref_type, ref_value}}) do
    [{:git, "#{repo_url}"}, {ref_type, "#{ref_value}"}]
  end
  defp convert_git({:git, repo_url}) do
    [{:git, "#{repo_url}"}]
  end
  defp convert_git({:git, repo_url, 'HEAD'}) do
    [{:git, "#{repo_url}"}]
  end
  defp convert_git({:git_subdir, repo_url, {ref_type, ref_value}, subdir_path}) do
    [{:git, "#{repo_url}"}, {ref_type, "#{ref_value}"}, {:sparse, "#{subdir_path}"}]
  end
end
