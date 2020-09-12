defmodule Shaker.Generator.Mix do

  @moduledoc """
  View for generating mix.exs file from prepared structure
  """

  @spec gen_module(atom(), [Macro.t()]) :: Macro.t()
  def gen_module(name, functions) do
    quote do
      defmodule unquote(name) do
        unquote_splicing(functions)
      end
    end
  end

end
