defmodule Shaker.Generator.Mix do
  @moduledoc """
  View for generating mix.exs file from prepared structure
  """

  @behaviour Shaker.Generator

  # 80 (max size of line)
  # - 2 * 3 (tabs)
  # - 3 (semicolon, space, comma)
  @maxlen 80 - 2 * 3 - 3

  alias Shaker.Generator.Function
  alias Shaker.Model.Mix, as: Model

  @spec gen(atom(), Model.t()) :: Macro.t()
  def gen(name, %{application: app, project: proj}) do
    [
      gen_funcs(:application, app),
      gen_funcs(:project, proj)
    ]
    |> List.flatten()
    |> gen_module(name)
  end

  defp gen_funcs(name, keyword) do
    {values, funcs} =
      Enum.reduce(keyword, {[], []}, fn {key, value}, {values, funcs} ->
        case gen_func_or_value(key, value) do
          {:value, val} ->
            {[{key, val} | values], funcs}

          {:func, fun} ->
            {[{key, quote(do: unquote(key)())} | values], [fun | funcs]}

          {:env_funcs, env_funcs} ->
            {
              [{key, quote(do: unquote(key)(Mix.env()))} | values],
              env_funcs ++ funcs
            }
        end
      end)

    [Function.gen_one(name, values, no_escape: true) | funcs]
  end

  @spec gen_func_or_value(atom(), Keyword.t())
  :: {:env_funcs, [{Macro.t(), any()}]} | {:value, any()} | {:func, Macro.t()}
  defp gen_func_or_value(key, "$anyenv": value) do
    if get_kv_len(key, value) > @maxlen do
      {:func, Function.gen_one(key, value)}
    else
      {:value, value}
    end
  end
  defp gen_func_or_value(key, env_pairs) do
    clauses =
      case Keyword.fetch(env_pairs, :"$anyenv") do
        {:ok, anyenv_pairs} ->
          env_pairs =
            env_pairs
            |> Keyword.delete(:"$anyenv")
            |> Enum.map(fn {env, pairs} ->
              {env, merge_vals(pairs, anyenv_pairs)}
            end)

          env_pairs ++ [{Macro.var(:_, nil), anyenv_pairs}]

        _ ->
          env_pairs
      end

    {:env_funcs, Function.gen_clauses(key, clauses)}
  end

  @spec gen_module([Macro.t()], atom()) :: Macro.t()
  defp gen_module(functions, name) do
    quote do
      defmodule unquote(name).MixProject do
        use Mix.Project
        unquote_splicing(functions)
      end
    end
  end

  @spec get_kv_len(atom(), any()) :: pos_integer()
  defp get_kv_len(key, value) do
    String.length(Atom.to_string(key)) + String.length(inspect(value))
  end

  defp merge_vals(vals1, vals2) when is_list(vals1) and is_list(vals2) do
    {kw1, v1} = split(vals1)
    {kw2, v2} = split(vals2)

    Keyword.merge(kw1, kw2) ++ Enum.uniq(v1 ++ v2)
  end
  defp merge_vals(_, vals2), do: vals2

  defp split(vals) do
    Enum.split_with(vals, fn
      {k, _} when is_atom(k) -> true
      _                      -> false
    end)
  end
end
