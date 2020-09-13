defmodule Shaker.Generator.Mix do
  @moduledoc """
  View for generating mix.exs file from prepared structure
  """

  @maxlen 80 - 2 - 2 - 2 - 3

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
  defp gen_func_or_value(key, pairs) do
    clauses =
      case Keyword.fetch(pairs, :"$anyenv") do
        {:ok, v} ->
          Keyword.delete(pairs, :"$anyenv") ++ [{Macro.var(:_, nil), v}]

        _ ->
          pairs
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
end
