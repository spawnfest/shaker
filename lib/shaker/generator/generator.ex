defmodule Shaker.Generator do

  @callback gen(atom(), Shaker.Model.t()) :: Macro.t()

end
