defmodule Shaker.Generator.Function do

  @moduledoc """
  Generates quoted def-function which returns keyword
  """

  @spec gen_one(atom(), Keyword.t()) :: Macro.t()
  def gen_one(name, keyword) do
    gen_func(name, [], keyword)
  end

  @spec gen_clauses(atom(), Keyword.t(Keyword.t())) :: Macro.t()
  def gen_clauses(name, clauses) do
    Enum.map(clauses, fn {arg, code} ->
      gen_func(name, [arg], code)
    end)
  end

  defp gen_func(name, args, body) do
    body = Macro.escape(body)
    quote do
      def unquote(name)(unquote_splicing(args)) do
        unquote(body)
      end
    end
  end

end
