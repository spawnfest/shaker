defmodule Shaker.Parsers do

  @callback parse(Shaker.Model.Mix.t(), Path.t()) :: Shaker.Model.Mix.t()

end
