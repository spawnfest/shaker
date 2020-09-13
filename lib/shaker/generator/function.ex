defmodule Shaker.Generator.Function do

  @moduledoc """
  Generates quoted def-functions
  """

  @type option :: {:no_escape, boolean()} | {:private, boolean()}
  @type options :: [option()]

  @spec gen_one(atom(), any(), options()) :: Macro.t()
  def gen_one(name, body, opts \\ []) do
    gen_func(name, [], body, opts)
  end

  @spec gen_clauses(atom(), Keyword.t(), options()) :: Macro.t()
  def gen_clauses(name, clauses, opts \\ []) do
    Enum.map(clauses, fn {arg, code} ->
      gen_func(name, [arg], code, opts)
    end)
  end

  defp gen_func(name, args, body, opts) do
    body = if(opts[:no_escape], do: body, else: Macro.escape(body))
    d = if(opts[:private], do: quote(do: defp), else: quote(do: def))
    quote do
      unquote(d)(unquote(name)(unquote_splicing(args))) do
        unquote(body)
      end
    end
  end
end
