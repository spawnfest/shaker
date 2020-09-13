defmodule Shaker.Parsers do

  @moduledoc """
  Simple behaviour for file parsers
  """

  @callback parse(Shaker.Model.Mix.t(), Path.t()) :: Shaker.Model.Mix.t()

end
