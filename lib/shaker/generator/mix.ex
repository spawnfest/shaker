defmodule Shaker.Generator.Mix do

  @moduledoc """
  View for generating mix.exs file from prepared structure
  """

  alias Shaker.Generator.Function

  @spec gen_module(atom(), [Macro.t()]) :: Macro.t()
  defp gen_module(name, functions) do
    quote do
      defmodule unquote(name) do
        unquote_splicing(functions)
      end
    end
  end

  def gen(params) do
    [
      gen_application(params),
      gen_project(params)
    ]
    |> List.flatten()
  end

  def gen_application(%{application: keyword}) do
    [Function.gen_one(:application, filter_empty(keyword))]
  end

  def gen_project(%{project: project}) do
    gen_flatten(:project, project, [:description, :project])
  end

  def gen_flatten(name, map_or_kw, keys) do
    keywords = filter_empty(map_or_kw)
    {kws, funcs} = gen_functions(keywords, keys)
    [Function.gen_one(name, Keyword.merge(keywords, kws)) | funcs]
  end

  # Replaces passed keys in keyword with calls to these separate functions
  @spec gen_functions(Keyword.t(), [atom()]) :: {Keyword.t(Macro.t()), [Macro.t()]}
  defp gen_functions(keyword, keys) do
    keyword
    |> Keyword.take(keys)
    |> Enum.reduce({[], []}, fn {key, keyword}, {kw, funcs} ->
      {
        [{key, quote(do: unquote(key)())} | kw],
        [Function.gen_one(key, filter_empty(keyword)) | funcs]
      }
    end)
  end

  # Helpers

  defguardp is_pairs(x) when is_map(x) or is_list(x)

  @spec filter_empty(any()) :: any()
  defp filter_empty(pairs) when is_pairs(pairs) do
    Enum.filter(pairs, fn {_, x} -> x != [] end)
  end
  defp filter_empty(other), do: other

  @spec to_block([Macro.t()]) :: Macro.t()
  def to_block(quoteds) do
    quote do
      unquote_splicing(quoteds)
    end
  end

end
