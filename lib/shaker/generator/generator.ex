defmodule Shaker.Generator do

  @moduledoc """
  Simple behaviour for modules generating ASTs from Models
  """

  @callback gen(atom(), Shaker.Model.t()) :: Macro.t()

end
